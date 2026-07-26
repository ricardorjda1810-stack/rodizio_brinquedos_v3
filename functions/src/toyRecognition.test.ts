import assert from "node:assert/strict";
import test from "node:test";
import type {
  Response as OpenAIResponse,
  ResponseCreateParamsNonStreaming,
} from "openai/resources/responses/responses";
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
  assertModelResponseHasOutputText,
  classifyRecognitionError,
  EmptyModelResponseError,
  IncompleteModelResponseError,
  InvalidModelResponseError,
  RecognitionErrorClassification,
  RecognitionFailureLogEntry,
  summarizeModelResponse,
  writeRecognitionFailureLog,
} from "./recognitionErrors";
import {
  buildRecognitionPrompt,
  createToyRecognitionResponse,
  parseRecognitionRequest,
  recognitionJsonSchema,
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

function simulatedResponse(
  overrides: Record<string, unknown>,
): OpenAIResponse {
  return {
    id: "sensitive-response-id",
    created_at: 0,
    output_text: "",
    error: null,
    incomplete_details: null,
    instructions: null,
    metadata: null,
    model: "gpt-5-mini",
    object: "response",
    output: [],
    parallel_tool_calls: false,
    temperature: null,
    tool_choice: "auto",
    tools: [],
    top_p: null,
    status: "completed",
    ...overrides,
  } as unknown as OpenAIResponse;
}

function captureError(callback: () => void): unknown {
  try {
    callback();
  } catch (error) {
    return error;
  }
  assert.fail("Expected callback to throw");
}

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

test("uses only the supported strict JSON Schema subset", () => {
  const schema = recognitionJsonSchema(
    categories.map((category) => category.id),
  );
  const forbiddenKeywords = new Set([
    "uniqueItems",
    "minLength",
    "maxLength",
  ]);

  function assertNoForbiddenKeywords(value: unknown): void {
    if (Array.isArray(value)) {
      value.forEach(assertNoForbiddenKeywords);
      return;
    }
    if (typeof value !== "object" || value === null) return;

    for (const [key, child] of Object.entries(value)) {
      assert.equal(forbiddenKeywords.has(key), false, `forbidden ${key}`);
      assertNoForbiddenKeywords(child);
    }
  }

  assertNoForbiddenKeywords(schema);
  assert.equal(schema.additionalProperties, false);
  assert.deepEqual(
    [...schema.required].sort(),
    Object.keys(schema.properties).sort(),
  );
  assert.equal(schema.properties.alternativeCategoryIds.maxItems, 2);
});

test("sends one low-effort request with the existing output contract", async () => {
  const request = parseRecognitionRequest({
    imageBase64: jpegBase64,
    mimeType: "image/jpeg",
    locale: "pt-BR",
    categories,
  });
  const categoryIds = categories.map((category) => category.id);
  const modelOutput = {
    status: "ok",
    suggestedName: "Blocos coloridos",
    categoryId: "maos",
    confidence: 0.94,
    alternativeCategoryIds: ["imaginacao"],
    explanation: "Peças para montar e empilhar.",
    needsReview: false,
  };
  const calls: ResponseCreateParamsNonStreaming[] = [];
  const response = await createToyRecognitionResponse(
    {
      create: async (params) => {
        calls.push(params);
        return simulatedResponse({
          status: "completed",
          output_text: JSON.stringify(modelOutput),
        });
      },
    },
    "gpt-5-mini",
    request,
    categoryIds,
  );

  assert.equal(calls.length, 1);
  assert.equal(calls[0].model, "gpt-5-mini");
  assert.equal(calls[0].store, false);
  assert.equal(calls[0].max_output_tokens, 2_000);
  assert.deepEqual(calls[0].reasoning, {effort: "low"});
  assert.deepEqual(calls[0].input, [
    {
      role: "user",
      content: [
        {type: "input_text", text: buildRecognitionPrompt(request)},
        {
          type: "input_image",
          detail: "low",
          image_url: `data:${request.mimeType};base64,${request.imageBase64}`,
        },
      ],
    },
  ]);
  assert.deepEqual(calls[0].text, {
    format: {
      type: "json_schema",
      name: "toy_recognition",
      strict: true,
      schema: recognitionJsonSchema(categoryIds),
    },
  });

  assert.doesNotThrow(() => assertModelResponseHasOutputText(response));
  const parsed = validateModelRecognition(
    JSON.parse(response.output_text),
    new Set(categoryIds),
  );
  assert.equal(parsed.suggestedName, "Blocos coloridos");
  assert.equal(parsed.categoryId, "maos");
});

test("does not retry an incomplete model response", async () => {
  let callCount = 0;
  const response = await createToyRecognitionResponse(
    {
      create: async () => {
        callCount += 1;
        return simulatedResponse({
          status: "incomplete",
          incomplete_details: {reason: "max_output_tokens"},
        });
      },
    },
    "gpt-5-mini",
    parseRecognitionRequest({
      imageBase64: jpegBase64,
      mimeType: "image/jpeg",
      locale: "pt-BR",
      categories,
    }),
    categories.map((category) => category.id),
  );

  assert.throws(
    () => assertModelResponseHasOutputText(response),
    IncompleteModelResponseError,
  );
  assert.equal(callCount, 1);
});

test("rejects duplicate alternative categories", () => {
  assert.throws(
    () => validateModelRecognition({
      status: "ok",
      suggestedName: "Blocos",
      categoryId: "maos",
      confidence: 0.9,
      alternativeCategoryIds: ["imaginacao", "imaginacao"],
      explanation: "Brinquedo de montar.",
      needsReview: false,
    }, new Set(categories.map((category) => category.id))),
    /invalid_model_response/,
  );
});

test("enforces local suggested name and explanation limits", () => {
  const allowedCategoryIds = new Set(
    categories.map((category) => category.id),
  );
  const validResult = {
    status: "ok",
    suggestedName: "a".repeat(80),
    categoryId: "maos",
    confidence: 0.9,
    alternativeCategoryIds: [],
    explanation: "b".repeat(240),
    needsReview: false,
  } as const;

  assert.doesNotThrow(
    () => validateModelRecognition(validResult, allowedCategoryIds),
  );
  assert.throws(
    () => validateModelRecognition({
      ...validResult,
      suggestedName: "a".repeat(81),
    }, allowedCategoryIds),
    /invalid_model_response/,
  );
  assert.throws(
    () => validateModelRecognition({
      ...validResult,
      explanation: "b".repeat(241),
    }, allowedCategoryIds),
    /invalid_model_response/,
  );
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

test("classifies incomplete reasoning-only responses without content", () => {
  const response = simulatedResponse({
    status: "incomplete",
    incomplete_details: {reason: "max_output_tokens"},
    output: [
      {
        id: "sensitive-reasoning-id",
        type: "reasoning",
        status: "incomplete",
        summary: [
          {type: "summary_text", text: "sensitive reasoning summary"},
        ],
        encrypted_content: "sensitive encrypted content",
      },
    ],
    usage: {
      input_tokens: 321,
      output_tokens: 400,
      output_tokens_details: {reasoning_tokens: 400},
      total_tokens: 721,
    },
  });

  const error = captureError(
    () => assertModelResponseHasOutputText(response),
  );
  assert.ok(error instanceof IncompleteModelResponseError);

  const classification = classifyRecognitionError(error);
  assert.equal(classification.category, "model_response_incomplete");
  assert.equal(classification.source, "model_response");
  assert.equal(classification.httpsCode, "internal");
  assert.equal(classification.responseStatus, "incomplete");
  assert.equal(classification.incompleteReason, "max_output_tokens");
  assert.equal(classification.outputItemCount, 1);
  assert.deepEqual(classification.outputItems, [
    {type: "reasoning", status: "incomplete"},
  ]);
  assert.equal(classification.hasOutputText, false);
  assert.equal(classification.outputTextLength, 0);
  assert.deepEqual(classification.usage, {
    input_tokens: 321,
    output_tokens: 400,
    output_tokens_details: {reasoning_tokens: 400},
    total_tokens: 721,
  });

  const entries: RecognitionFailureLogEntry[] = [];
  writeRecognitionFailureLog(
    (entry) => entries.push(entry),
    "00000000-0000-4000-8000-000000000002",
    classification,
  );
  const serialized = JSON.stringify(entries[0]);
  for (const forbidden of [
    "sensitive-response-id",
    "sensitive-reasoning-id",
    "sensitive reasoning summary",
    "sensitive encrypted content",
  ]) {
    assert.equal(serialized.includes(forbidden), false);
  }
});

test("classifies incomplete responses even without a reason", () => {
  const error = captureError(() => assertModelResponseHasOutputText(
    simulatedResponse({
      status: "incomplete",
      incomplete_details: null,
      output: [{type: "reasoning", status: "incomplete", summary: []}],
    }),
  ));

  assert.ok(error instanceof IncompleteModelResponseError);
  const classification = classifyRecognitionError(error);
  assert.equal(classification.category, "model_response_incomplete");
  assert.equal(classification.responseStatus, "incomplete");
  assert.equal(classification.incompleteReason, undefined);
});

test("accepts completed responses with visible output text", () => {
  const response = simulatedResponse({
    status: "completed",
    output_text: "{\"status\":\"ok\"}",
    output: [
      {
        type: "message",
        status: "completed",
        content: [
          {type: "output_text", text: "sensitive model output"},
        ],
      },
    ],
  });
  const metadata = summarizeModelResponse(response);

  assert.doesNotThrow(() => assertModelResponseHasOutputText(response));
  assert.equal(metadata.responseStatus, "completed");
  assert.equal(metadata.hasOutputText, true);
  assert.equal(metadata.outputTextLength, 15);
  assert.deepEqual(metadata.outputItems, [
    {
      type: "message",
      status: "completed",
      contentTypes: ["output_text"],
    },
  ]);
  assert.equal(
    JSON.stringify(metadata).includes("sensitive model output"),
    false,
  );
});

test("keeps completed empty responses classified as empty", () => {
  const error = captureError(() => assertModelResponseHasOutputText(
    simulatedResponse({
      status: "completed",
      output_text: "",
      output: [],
    }),
  ));

  assert.ok(error instanceof EmptyModelResponseError);
  const classification = classifyRecognitionError(error);
  assert.equal(classification.category, "empty_model_response");
  assert.equal(classification.responseStatus, "completed");
  assert.equal(classification.outputItemCount, 0);
  assert.deepEqual(classification.outputItems, []);
  assert.equal(classification.hasOutputText, false);
});

test("records refusal type without recording refusal text", () => {
  const response = simulatedResponse({
    status: "completed",
    output_text: "",
    output: [
      {
        type: "message",
        status: "completed",
        content: [
          {type: "refusal", refusal: "sensitive refusal text"},
        ],
      },
    ],
  });
  const error = captureError(
    () => assertModelResponseHasOutputText(response),
  );
  const classification = classifyRecognitionError(error);
  const entries: RecognitionFailureLogEntry[] = [];
  writeRecognitionFailureLog(
    (entry) => entries.push(entry),
    "00000000-0000-4000-8000-000000000003",
    classification,
  );

  assert.deepEqual(entries[0].outputItems, [
    {
      type: "message",
      status: "completed",
      contentTypes: ["refusal"],
    },
  ]);
  assert.equal(
    JSON.stringify(entries[0]).includes("sensitive refusal text"),
    false,
  );
});

test("bounds arrays and omits malformed response metadata", () => {
  const output = [
    {
      type: "message",
      status: "completed\nunexpected",
      content: [
        {type: "refusal"},
        {type: "x".repeat(100)},
        ...Array.from({length: 10}, () => ({type: "output_text"})),
      ],
    },
    {type: "x".repeat(100), status: "completed"},
    ...Array.from(
      {length: 10},
      () => ({type: "reasoning", status: "completed", summary: []}),
    ),
  ];
  const metadata = summarizeModelResponse(simulatedResponse({
    status: "x".repeat(100),
    incomplete_details: {reason: "unexpected\nreason"},
    output_text: 123,
    output,
    usage: {
      input_tokens: -1,
      output_tokens: 1.5,
      output_tokens_details: {reasoning_tokens: "400"},
      total_tokens: Number.NaN,
    },
  }));

  assert.equal(metadata.responseStatus, undefined);
  assert.equal(metadata.incompleteReason, undefined);
  assert.equal(metadata.outputItemCount, 12);
  assert.equal(metadata.outputItems?.length, 7);
  assert.deepEqual(metadata.outputItems?.[0], {
    type: "message",
    contentTypes: [
      "refusal",
      "output_text",
      "output_text",
      "output_text",
      "output_text",
      "output_text",
      "output_text",
    ],
  });
  assert.equal(metadata.hasOutputText, false);
  assert.equal(metadata.outputTextLength, 0);
  assert.equal(metadata.usage, undefined);
});

test("records only allowed non-negative usage integers", () => {
  const metadata = summarizeModelResponse(simulatedResponse({
    usage: {
      input_tokens: 100,
      output_tokens: 80,
      output_tokens_details: {
        reasoning_tokens: 60,
        sensitive_detail: "sensitive usage detail",
      },
      total_tokens: 180,
      message: "sensitive usage message",
      payload: "sensitive usage payload",
    },
  }));

  assert.deepEqual(metadata.usage, {
    input_tokens: 100,
    output_tokens: 80,
    output_tokens_details: {reasoning_tokens: 60},
    total_tokens: 180,
  });
  const serialized = JSON.stringify(metadata);
  assert.equal(serialized.includes("sensitive usage detail"), false);
  assert.equal(serialized.includes("sensitive usage message"), false);
  assert.equal(serialized.includes("sensitive usage payload"), false);
});

const responseHeaders = new Headers({
  authorization: "sensitive-header",
});

const apiErrorBody = {
  code: "arbitrary-external-code",
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

test("preserves safe provider metadata in classifications and logs", () => {
  const allowedError = new RateLimitError(
    429,
    {
      type: "invalid_request_error",
      code: "rate_limit_exceeded",
      param: "text.format.schema",
      message: "sensitive provider message",
    },
    "sensitive message",
    responseHeaders,
  );
  const allowedClassification = classifyRecognitionError(allowedError);
  assert.equal(allowedClassification.providerType, "invalid_request_error");
  assert.equal(allowedClassification.providerCode, "rate_limit_exceeded");
  assert.equal(allowedClassification.providerParam, "text.format.schema");

  const entries: RecognitionFailureLogEntry[] = [];
  writeRecognitionFailureLog(
    (entry) => entries.push(entry),
    "00000000-0000-4000-8000-000000000000",
    allowedClassification,
  );
  assert.equal(entries[0].providerType, "invalid_request_error");
  assert.equal(entries[0].providerCode, "rate_limit_exceeded");
  assert.equal(entries[0].providerParam, "text.format.schema");
  assert.equal(
    JSON.stringify(entries).includes("sensitive provider message"),
    false,
  );
  assert.equal(JSON.stringify(entries).includes("sensitive message"), false);
});

test("omits unsafe provider metadata without throwing", () => {
  const unsafeError = new BadRequestError(
    400,
    {
      type: `invalid_${"x".repeat(64)}`,
      code: "invalid-json-schema",
      param: "text.format.schema\npayload",
      message: "sensitive provider message",
    },
    "sensitive message",
    responseHeaders,
  );
  const classification = classifyRecognitionError(unsafeError);

  assert.equal(classification.category, "openai_bad_request");
  assert.equal(classification.httpStatus, 400);
  assert.equal(classification.providerType, undefined);
  assert.equal(classification.providerCode, undefined);
  assert.equal(classification.providerParam, undefined);

  const entries: RecognitionFailureLogEntry[] = [];
  assert.doesNotThrow(() => writeRecognitionFailureLog(
    (entry) => entries.push(entry),
    "00000000-0000-4000-8000-000000000001",
    {
      ...classification,
      providerType: 123,
      providerCode: "invalid code",
      providerParam: "x".repeat(161),
    } as unknown as RecognitionErrorClassification,
  ));
  assert.equal(entries[0].providerType, undefined);
  assert.equal(entries[0].providerCode, undefined);
  assert.equal(entries[0].providerParam, undefined);
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
    providerType: "invalid\ntype",
    providerCode: "arbitrary-external-code",
    providerParam: "text.format.schema payload",
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
    "arbitrary-external-code",
  ]) {
    assert.equal(serialized.includes(forbidden), false);
  }
});
