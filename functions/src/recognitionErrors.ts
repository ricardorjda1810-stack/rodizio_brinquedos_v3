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
  const providerType = sanitizeProviderIdentifier(
    classification.providerType,
    PROVIDER_TYPE_MAX_LENGTH,
  );
  const providerCode = sanitizeProviderCode(classification.providerCode);
  const providerParam = sanitizeProviderParam(classification.providerParam);
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
