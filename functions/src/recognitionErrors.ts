import {
  APIConnectionError,
  APIConnectionTimeoutError,
  APIError,
  AuthenticationError,
  BadRequestError,
  PermissionDeniedError,
  RateLimitError,
} from "openai";

export type RecognitionFailureCategory =
  | "openai_api_error"
  | "openai_rate_limit"
  | "openai_authentication"
  | "openai_permission"
  | "openai_bad_request"
  | "openai_timeout"
  | "openai_connection"
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

export type RecognitionErrorClassification = {
  category: RecognitionFailureCategory;
  source: RecognitionFailureSource;
  httpsCode: RecognitionHttpsCode;
  httpStatus?: number;
  providerCode?: string;
};

export type RecognitionFailureLogEntry = RecognitionErrorClassification & {
  severity: "ERROR";
  event: "recognize_toy_failure";
  correlationId: string;
};

const allowedProviderCodes: ReadonlySet<string> = new Set([
  "server_error",
  "rate_limit_exceeded",
  "invalid_prompt",
  "invalid_image",
  "image_content_policy_violation",
]);

export class EmptyModelResponseError extends Error {
  constructor() {
    super("empty_model_response");
  }
}

export class InvalidModelResponseError extends Error {
  constructor() {
    super("invalid_model_response");
  }
}

export function classifyRecognitionError(
  error: unknown,
): RecognitionErrorClassification {
  if (error instanceof EmptyModelResponseError) {
    return {
      category: "empty_model_response",
      source: "model_response",
      httpsCode: "internal",
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
  const providerCode = sanitizeProviderCode(classification.providerCode);
  writer({
    severity: "ERROR",
    event: "recognize_toy_failure",
    correlationId,
    source: classification.source,
    category: classification.category,
    httpsCode: classification.httpsCode,
    ...(httpStatus === undefined ? {} : {httpStatus}),
    ...(providerCode === undefined ? {} : {providerCode}),
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
  const providerCode = sanitizeProviderCode(error.code);
  return {
    category,
    source: "openai",
    httpsCode,
    ...(httpStatus === undefined ? {} : {httpStatus}),
    ...(providerCode === undefined ? {} : {providerCode}),
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
  if (typeof code !== "string") return undefined;
  // Unknown provider values are deliberately omitted instead of being logged.
  return allowedProviderCodes.has(code) ? code : undefined;
}
