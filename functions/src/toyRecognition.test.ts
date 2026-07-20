import assert from "node:assert/strict";
import test from "node:test";

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
