import {
  APIConnectionError,
  APIConnectionTimeoutError,
  APIError,
  AuthenticationError,
  BadRequestError,
  PermissionDeniedError,
  RateLimitError,
} from "openai";
import type {Response as OpenAIResponse} from "openai/resources/responses/responses";

export type RecognitionFailureCategory =
  | "openai_api_error"
  | "openai_rate_limit"
  | "openai_authentication"
  | "openai_permission"
  | "openai_bad_request"
  | "openai_timeout"
  | "openai_connection"
  | "model_response_incomplete"
  | "empty_model_response"
  | "invalid_model_response"
  | "unexpected_error";

export type RecognitionFailureSource =
  | "openai"
  | "model_response"
  | "backend";

export type RecognitionHttpsCode =
  | "resource-exhausted"
  | "unavailable"
  | "internal";

export type ModelResponseOutputItemMetadata = {
  type: string;
  status?: string;
  contentTypes?: string[];
};

export type ModelResponseUsageMetadata = {
  input_tokens?: number;
  output_tokens?: number;
  output_tokens_details?: {
    reasoning_tokens?: number;
  };
  total_tokens?: number;
};

export type ModelResponseMetadata = {
  responseStatus?: string;
  incompleteReason?: string;
  outputItemCount?: number;
  outputItems?: ModelResponseOutputItemMetadata[];
  hasOutputText?: boolean;
  outputTextLength?: number;
  usage?: ModelResponseUsageMetadata;
};

export type RecognitionErrorClassification = ModelResponseMetadata & {
  category: RecognitionFailureCategory;
  source: RecognitionFailureSource;
  httpsCode: RecognitionHttpsCode;
  httpStatus?: number;
  providerType?: string;
  providerCode?: string;
  providerParam?: string;
};

export type RecognitionFailureLogEntry = RecognitionErrorClassification & {
  severity: "ERROR";
  event: "recognize_toy_failure";
  correlationId: string;
};

const PROVIDER_TYPE_MAX_LENGTH = 64;
const PROVIDER_CODE_MAX_LENGTH = 64;
const PROVIDER_PARAM_MAX_LENGTH = 160;
const providerIdentifierPattern = /^[a-z][a-z0-9_]*$/;
const providerParamPattern = /^[A-Za-z0-9_.\[\]-]+$/;
const MAX_OUTPUT_ITEMS = 8;
const MAX_CONTENT_TYPES = 8;
const allowedResponseStatuses: ReadonlySet<string> = new Set([
  "completed",
  "failed",
  "in_progress",
  "cancelled",
  "queued",
  "incomplete",
]);
const allowedIncompleteReasons: ReadonlySet<string> = new Set([
  "max_output_tokens",
  "content_filter",
]);
const allowedOutputItemTypes: ReadonlySet<string> = new Set([
  "message",
  "reasoning",
]);
const allowedOutputItemStatuses: ReadonlySet<string> = new Set([
  "in_progress",
  "completed",
  "incomplete",
]);
const allowedContentTypes: ReadonlySet<string> = new Set([
  "output_text",
  "refusal",
  "reasoning_text",
]);

export class EmptyModelResponseError extends Error {
  readonly responseMetadata: ModelResponseMetadata;

  constructor(responseMetadata: ModelResponseMetadata = {}) {
    super("empty_model_response");
    this.responseMetadata = responseMetadata;
  }
}

export class IncompleteModelResponseError extends Error {
  readonly responseMetadata: ModelResponseMetadata;

  constructor(responseMetadata: ModelResponseMetadata = {}) {
    super("model_response_incomplete");
    this.responseMetadata = responseMetadata;
  }
}

export class InvalidModelResponseError extends Error {
  constructor() {
    super("invalid_model_response");
  }
}

export function summarizeModelResponse(
  response: OpenAIResponse,
): ModelResponseMetadata {
  if (!isRecord(response)) return {};

  const outputText = typeof response.output_text === "string" ?
    response.output_text :
    "";
  const output = Array.isArray(response.output) ? response.output : undefined;
  const incompleteDetails = isRecord(response.incomplete_details) ?
    response.incomplete_details :
    undefined;

  return sanitizeModelResponseMetadata({
    responseStatus: response.status,
    incompleteReason: incompleteDetails?.reason,
    ...(output === undefined ? {} : {
      outputItemCount: output.length,
      outputItems: output.map(summarizeOutputItem),
    }),
    hasOutputText: outputText.length > 0,
    outputTextLength: outputText.length,
    usage: response.usage,
  });
}

export function assertModelResponseHasOutputText(
  response: OpenAIResponse,
): void {
  const responseMetadata = summarizeModelResponse(response);
  if (responseMetadata.responseStatus === "incomplete") {
    throw new IncompleteModelResponseError(responseMetadata);
  }
  if (!responseMetadata.hasOutputText) {
    throw new EmptyModelResponseError(responseMetadata);
  }
}

export function classifyRecognitionError(
  error: unknown,
): RecognitionErrorClassification {
  if (error instanceof IncompleteModelResponseError) {
    return {
      category: "model_response_incomplete",
      source: "model_response",
      httpsCode: "internal",
      ...sanitizeModelResponseMetadata(error.responseMetadata),
    };
  }
  if (error instanceof EmptyModelResponseError) {
    return {
      category: "empty_model_response",
      source: "model_response",
      httpsCode: "internal",
      ...sanitizeModelResponseMetadata(error.responseMetadata),
    };
  }
  if (error instanceof InvalidModelResponseError || error instanceof SyntaxError) {
    return {
      category: "invalid_model_response",
      source: "model_response",
      httpsCode: "internal",
    };
  }
  if (error instanceof APIConnectionTimeoutError) {
    return openAiClassification("openai_timeout", "unavailable", error);
  }
  if (error instanceof APIConnectionError) {
    return openAiClassification("openai_connection", "unavailable", error);
  }
  if (error instanceof RateLimitError || isApiStatus(error, 429)) {
    return openAiClassification(
      "openai_rate_limit",
      "resource-exhausted",
      error,
    );
  }
  if (error instanceof AuthenticationError || isApiStatus(error, 401)) {
    return openAiClassification("openai_authentication", "internal", error);
  }
  if (error instanceof PermissionDeniedError || isApiStatus(error, 403)) {
    return openAiClassification("openai_permission", "internal", error);
  }
  if (error instanceof BadRequestError || isApiStatus(error, 400)) {
    return openAiClassification("openai_bad_request", "internal", error);
  }
  if (error instanceof APIError) {
    const httpsCode = error.status !== undefined && error.status >= 500 ?
      "unavailable" :
      "internal";
    return openAiClassification(
      "openai_api_error",
      httpsCode,
      error,
    );
  }
  return {
    category: "unexpected_error",
    source: "backend",
    httpsCode: "internal",
  };
}

export function writeRecognitionFailureLog(
  writer: (entry: RecognitionFailureLogEntry) => void,
  correlationId: string,
  classification: RecognitionErrorClassification,
): void {
  const httpStatus = sanitizeHttpStatus(classification.httpStatus);
  const providerType = sanitizeProviderIdentifier(
    classification.providerType,
    PROVIDER_TYPE_MAX_LENGTH,
  );
  const providerCode = sanitizeProviderCode(classification.providerCode);
  const providerParam = sanitizeProviderParam(classification.providerParam);
  const responseMetadata = sanitizeModelResponseMetadata(classification);
  writer({
    severity: "ERROR",
    event: "recognize_toy_failure",
    correlationId,
    source: classification.source,
    category: classification.category,
    httpsCode: classification.httpsCode,
    ...(httpStatus === undefined ? {} : {httpStatus}),
    ...(providerType === undefined ? {} : {providerType}),
    ...(providerCode === undefined ? {} : {providerCode}),
    ...(providerParam === undefined ? {} : {providerParam}),
    ...responseMetadata,
  });
}

function isApiStatus(error: unknown, status: number): error is APIError {
  return error instanceof APIError && error.status === status;
}

function openAiClassification(
  category: RecognitionFailureCategory,
  httpsCode: RecognitionHttpsCode,
  error: APIError,
): RecognitionErrorClassification {
  const httpStatus = sanitizeHttpStatus(error.status);
  const providerType = sanitizeProviderIdentifier(
    error.type,
    PROVIDER_TYPE_MAX_LENGTH,
  );
  const providerCode = sanitizeProviderCode(error.code);
  const providerParam = sanitizeProviderParam(error.param);
  return {
    category,
    source: "openai",
    httpsCode,
    ...(httpStatus === undefined ? {} : {httpStatus}),
    ...(providerType === undefined ? {} : {providerType}),
    ...(providerCode === undefined ? {} : {providerCode}),
    ...(providerParam === undefined ? {} : {providerParam}),
  };
}

function sanitizeHttpStatus(status: number | undefined): number | undefined {
  if (status === undefined || !Number.isInteger(status) ||
      status < 100 || status > 599) {
    return undefined;
  }
  return status;
}

function sanitizeProviderCode(code: unknown): string | undefined {
  return sanitizeProviderIdentifier(code, PROVIDER_CODE_MAX_LENGTH);
}

function sanitizeProviderParam(param: unknown): string | undefined {
  if (typeof param !== "string" || param.length === 0 ||
      param.length > PROVIDER_PARAM_MAX_LENGTH ||
      !providerParamPattern.test(param)) {
    return undefined;
  }
  return param;
}

function sanitizeProviderIdentifier(
  value: unknown,
  maxLength: number,
): string | undefined {
  if (typeof value !== "string" || value.length === 0 ||
      value.length > maxLength || !providerIdentifierPattern.test(value)) {
    return undefined;
  }
  return value;
}

function summarizeOutputItem(
  item: unknown,
): ModelResponseOutputItemMetadata {
  if (!isRecord(item)) return {type: ""};

  return {
    type: item.type,
    status: item.status,
    contentTypes: Array.isArray(item.content) ?
      item.content.map((content) => isRecord(content) ? content.type : "") :
      undefined,
  } as ModelResponseOutputItemMetadata;
}

function sanitizeModelResponseMetadata(
  metadata: unknown,
): ModelResponseMetadata {
  if (!isRecord(metadata)) return {};

  const responseStatus = sanitizeKnownString(
    metadata.responseStatus,
    allowedResponseStatuses,
  );
  const incompleteReason = sanitizeKnownString(
    metadata.incompleteReason,
    allowedIncompleteReasons,
  );
  const outputItemCount = sanitizeNonNegativeInteger(metadata.outputItemCount);
  const outputItems = sanitizeOutputItems(metadata.outputItems);
  const hasOutputText = typeof metadata.hasOutputText === "boolean" ?
    metadata.hasOutputText :
    undefined;
  const outputTextLength = sanitizeNonNegativeInteger(
    metadata.outputTextLength,
  );
  const usage = sanitizeUsage(metadata.usage);

  return {
    ...(responseStatus === undefined ? {} : {responseStatus}),
    ...(incompleteReason === undefined ? {} : {incompleteReason}),
    ...(outputItemCount === undefined ? {} : {outputItemCount}),
    ...(outputItems === undefined ? {} : {outputItems}),
    ...(hasOutputText === undefined ? {} : {hasOutputText}),
    ...(outputTextLength === undefined ? {} : {outputTextLength}),
    ...(usage === undefined ? {} : {usage}),
  };
}

function sanitizeOutputItems(
  value: unknown,
): ModelResponseOutputItemMetadata[] | undefined {
  if (!Array.isArray(value)) return undefined;

  const outputItems: ModelResponseOutputItemMetadata[] = [];
  for (const rawItem of value.slice(0, MAX_OUTPUT_ITEMS)) {
    if (!isRecord(rawItem)) continue;
    const type = sanitizeKnownString(rawItem.type, allowedOutputItemTypes);
    if (type === undefined) continue;

    const status = sanitizeKnownString(
      rawItem.status,
      allowedOutputItemStatuses,
    );
    const contentTypes = sanitizeContentTypes(rawItem.contentTypes);
    outputItems.push({
      type,
      ...(status === undefined ? {} : {status}),
      ...(contentTypes === undefined ? {} : {contentTypes}),
    });
  }
  return outputItems;
}

function sanitizeContentTypes(value: unknown): string[] | undefined {
  if (!Array.isArray(value)) return undefined;

  const contentTypes: string[] = [];
  for (const rawType of value.slice(0, MAX_CONTENT_TYPES)) {
    const type = sanitizeKnownString(rawType, allowedContentTypes);
    if (type !== undefined) contentTypes.push(type);
  }
  return contentTypes;
}

function sanitizeUsage(value: unknown): ModelResponseUsageMetadata | undefined {
  if (!isRecord(value)) return undefined;

  const inputTokens = sanitizeNonNegativeInteger(value.input_tokens);
  const outputTokens = sanitizeNonNegativeInteger(value.output_tokens);
  const totalTokens = sanitizeNonNegativeInteger(value.total_tokens);
  const outputDetails = isRecord(value.output_tokens_details) ?
    value.output_tokens_details :
    undefined;
  const reasoningTokens = sanitizeNonNegativeInteger(
    outputDetails?.reasoning_tokens,
  );

  if (inputTokens === undefined && outputTokens === undefined &&
      totalTokens === undefined && reasoningTokens === undefined) {
    return undefined;
  }
  return {
    ...(inputTokens === undefined ? {} : {input_tokens: inputTokens}),
    ...(outputTokens === undefined ? {} : {output_tokens: outputTokens}),
    ...(reasoningTokens === undefined ? {} : {
      output_tokens_details: {reasoning_tokens: reasoningTokens},
    }),
    ...(totalTokens === undefined ? {} : {total_tokens: totalTokens}),
  };
}

function sanitizeKnownString(
  value: unknown,
  allowedValues: ReadonlySet<string>,
): string | undefined {
  return typeof value === "string" && allowedValues.has(value) ?
    value :
    undefined;
}

function sanitizeNonNegativeInteger(value: unknown): number | undefined {
  return typeof value === "number" && Number.isSafeInteger(value) &&
    value >= 0 ?
    value :
    undefined;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
