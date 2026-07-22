import assert from "node:assert/strict";
import test from "node:test";
import {
  APIConnectionError,
  APIConnectionTimeoutError,
  AuthenticationError,
  BadRequestError,
  InternalServerError,
  PermissionDeniedError,
  RateLimitError,
} from "openai";

import {
  classifyRecognitionError,
  EmptyModelResponseError,
  InvalidModelResponseError,
  RecognitionErrorClassification,
  RecognitionFailureLogEntry,
  writeRecognitionFailureLog,
} from "./recognitionErrors";
import {
  buildRecognitionPrompt,
  parseRecognitionRequest,
  validateModelRecognition,
} from "./toyRecognition";

const categories = [
  {
    id: "maos",
    name: "Mãos e Construção",
    examples: "encaixar e empilhar",
    developmentAspect: "coordenação",
  },
  {
    id: "imaginacao",
    name: "Imaginação e Criatividade",
    examples: "faz de conta",
    developmentAspect: "expressão",
  },
];

const jpegBase64 = Buffer.from([
  0xff, 0xd8, 0xff, 0xe0, 0x00, 0x10,
]).toString("base64");

test("parses a bounded recognition request", () => {
  const request = parseRecognitionRequest({
    imageBase64: jpegBase64,
    mimeType: "image/jpeg",
    locale: "pt-BR",
    categories,
  });

  assert.equal(request.categories.length, 2);
  assert.match(buildRecognitionPrompt(request), /maos: Mãos e Construção/);
});

test("rejects unsupported image formats", () => {
  assert.throws(
    () => parseRecognitionRequest({
      imageBase64: jpegBase64,
      mimeType: "image/heic",
      locale: "pt-BR",
      categories,
    }),
    /invalid_image/,
  );
});

test("rejects content that does not match the declared image format", () => {
  assert.throws(
    () => parseRecognitionRequest({
      imageBase64: Buffer.from("not an image").toString("base64"),
      mimeType: "image/jpeg",
      locale: "pt-BR",
      categories,
    }),
    /invalid_image/,
  );
});

test("rejects a non-canonical base64 image", () => {
  const paddedJpeg = Buffer.from([
    0xff, 0xd8, 0xff, 0xe0,
  ]).toString("base64");
  const nonCanonicalJpeg = `${paddedJpeg.slice(0, -3)}B==`;

  assert.throws(
    () => parseRecognitionRequest({
      imageBase64: nonCanonicalJpeg,
      mimeType: "image/jpeg",
      locale: "pt-BR",
      categories,
    }),
    /invalid_image/,
  );
});

test("rejects a locale outside pt-BR and en-US", () => {
  assert.throws(
    () => parseRecognitionRequest({
      imageBase64: jpegBase64,
      mimeType: "image/jpeg",
      locale: "ignore rules",
      categories,
    }),
    /invalid_locale/,
  );
});

test("rejects duplicate category ids", () => {
  assert.throws(
    () => parseRecognitionRequest({
      imageBase64: jpegBase64,
      mimeType: "image/jpeg",
      locale: "en-US",
      categories: [categories[0], categories[0]],
    }),
    /invalid_categories/,
  );
});

test("validates and normalizes the model result", () => {
  const result = validateModelRecognition({
    status: "ok",
    suggestedName: "  Blocos coloridos  ",
    categoryId: "maos",
    confidence: 0.94,
    alternativeCategoryIds: ["imaginacao"],
    explanation: "Peças para montar e empilhar.",
    needsReview: false,
  }, new Set(categories.map((category) => category.id)));

  assert.equal(result.suggestedName, "Blocos coloridos");
  assert.equal(result.confidence, 0.94);
  assert.deepEqual(result.alternativeCategoryIds, ["imaginacao"]);
});

test("rejects a category outside the supplied taxonomy", () => {
  assert.throws(
    () => validateModelRecognition({
      status: "ok",
      suggestedName: "Carrinho",
      categoryId: "veiculos",
      confidence: 0.9,
      alternativeCategoryIds: [],
      explanation: "Brinquedo com rodas.",
      needsReview: false,
    }, new Set(categories.map((category) => category.id))),
    /invalid_model_response/,
  );
});

test("rejects malformed ok model output instead of coercing it", () => {
  assert.throws(
    () => validateModelRecognition({
      status: "ok",
      suggestedName: "Carrinho",
      categoryId: "maos",
      confidence: Number.NaN,
      alternativeCategoryIds: [],
      explanation: "Brinquedo com rodas.",
      needsReview: false,
    }, new Set(categories.map((category) => category.id))),
    /invalid_model_response/,
  );
});

test("preserves privacy and ambiguity rejection statuses", () => {
  for (const status of ["person_detected", "multiple_toys", "no_toy"] as const) {
    const allowedCategoryIds = new Set(categories.map((category) => category.id));
    const result = validateModelRecognition({
      status,
      suggestedName: "",
      categoryId: "",
      confidence: 0,
      alternativeCategoryIds: [],
      explanation: "",
      needsReview: true,
    }, allowedCategoryIds);

    assert.equal(result.status, status);
  }
});

const responseHeaders = new Headers({
  authorization: "sensitive-header",
});

const apiErrorBody = {
  code: "arbitrary_external_code",
  type: "sensitive-provider-type",
};

test("classifies OpenAI HTTP failures without exposing raw errors", () => {
  const cases = [
    {
      error: new BadRequestError(
        400,
        apiErrorBody,
        "sensitive message",
        responseHeaders,
      ),
      category: "openai_bad_request",
      httpsCode: "internal",
    },
    {
      error: new AuthenticationError(
        401,
        apiErrorBody,
        "sensitive message",
        responseHeaders,
      ),
      category: "openai_authentication",
      httpsCode: "internal",
    },
    {
      error: new PermissionDeniedError(
        403,
        apiErrorBody,
        "sensitive message",
        responseHeaders,
      ),
      category: "openai_permission",
      httpsCode: "internal",
    },
    {
      error: new RateLimitError(
        429,
        apiErrorBody,
        "sensitive message",
        responseHeaders,
      ),
      category: "openai_rate_limit",
      httpsCode: "resource-exhausted",
    },
    {
      error: new InternalServerError(
        503,
        apiErrorBody,
        "sensitive message",
        responseHeaders,
      ),
      category: "openai_api_error",
      httpsCode: "unavailable",
    },
  ] as const;

  for (const item of cases) {
    const result = classifyRecognitionError(item.error);
    assert.equal(result.category, item.category);
    assert.equal(result.httpsCode, item.httpsCode);
    assert.equal(result.source, "openai");
    assert.equal(result.httpStatus, item.error.status);
    assert.equal(result.providerCode, undefined);
  }
});

test("allows only known provider codes in classifications and logs", () => {
  const allowedError = new RateLimitError(
    429,
    {code: "rate_limit_exceeded"},
    "sensitive message",
    responseHeaders,
  );
  const allowedClassification = classifyRecognitionError(allowedError);
  assert.equal(allowedClassification.providerCode, "rate_limit_exceeded");

  const unknownError = new BadRequestError(
    400,
    {code: "arbitrary_external_code"},
    "sensitive message",
    responseHeaders,
  );
  const unknownClassification = classifyRecognitionError(unknownError);
  assert.equal(unknownClassification.category, "openai_bad_request");
  assert.equal(unknownClassification.httpStatus, 400);
  assert.equal(unknownClassification.providerCode, undefined);

  const entries: RecognitionFailureLogEntry[] = [];
  writeRecognitionFailureLog(
    (entry) => entries.push(entry),
    "00000000-0000-4000-8000-000000000000",
    allowedClassification,
  );
  writeRecognitionFailureLog(
    (entry) => entries.push(entry),
    "00000000-0000-4000-8000-000000000001",
    unknownClassification,
  );
  assert.equal(entries[0].providerCode, "rate_limit_exceeded");
  assert.equal(entries[1].providerCode, undefined);
  assert.equal(JSON.stringify(entries).includes("arbitrary_external_code"), false);
});

test("classifies OpenAI timeout and connection failures", () => {
  assert.deepEqual(
    classifyRecognitionError(new APIConnectionTimeoutError()),
    {
      category: "openai_timeout",
      source: "openai",
      httpsCode: "unavailable",
    },
  );
  assert.deepEqual(
    classifyRecognitionError(new APIConnectionError({})),
    {
      category: "openai_connection",
      source: "openai",
      httpsCode: "unavailable",
    },
  );
});

test("classifies empty, invalid, and unexpected responses", () => {
  assert.equal(
    classifyRecognitionError(new EmptyModelResponseError()).category,
    "empty_model_response",
  );
  assert.equal(
    classifyRecognitionError(new InvalidModelResponseError()).category,
    "invalid_model_response",
  );
  assert.equal(
    classifyRecognitionError(new Error("sensitive message")).category,
    "unexpected_error",
  );
});

test("structured failure logging contains only allowlisted fields", () => {
  const entries: RecognitionFailureLogEntry[] = [];
  const malformedClassification = {
    category: "openai_rate_limit",
    source: "openai",
    httpsCode: "resource-exhausted",
    httpStatus: 429,
    providerCode: "arbitrary_external_code",
    message: "sensitive-message",
    stack: "sensitive-stack",
    headers: {authorization: "sensitive-header"},
    prompt: "sensitive-prompt",
    image: "sensitive-image",
    base64: "sensitive-base64",
    response: "sensitive-response",
    apiKey: "sensitive-api-key",
    token: "sensitive-token",
    unexpectedProperty: "sensitive-unexpected-property",
  } as unknown as RecognitionErrorClassification;

  writeRecognitionFailureLog(
    (entry) => entries.push(entry),
    "00000000-0000-4000-8000-000000000000",
    malformedClassification,
  );

  assert.equal(entries.length, 1);
  assert.deepEqual(Object.keys(entries[0]).sort(), [
    "category",
    "correlationId",
    "event",
    "httpStatus",
    "httpsCode",
    "severity",
    "source",
  ]);
  assert.deepEqual(entries[0], {
    severity: "ERROR",
    event: "recognize_toy_failure",
    correlationId: "00000000-0000-4000-8000-000000000000",
    category: "openai_rate_limit",
    source: "openai",
    httpsCode: "resource-exhausted",
    httpStatus: 429,
  });

  const serialized = JSON.stringify(entries[0]);
  for (const forbidden of [
    "sensitive-message",
    "sensitive-stack",
    "sensitive-header",
    "sensitive-image",
    "sensitive-base64",
    "sensitive-prompt",
    "sensitive-response",
    "sensitive-api-key",
    "sensitive-token",
    "sensitive-unexpected-property",
    "arbitrary_external_code",
  ]) {
    assert.equal(serialized.includes(forbidden), false);
  }
});
