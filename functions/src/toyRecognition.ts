import {InvalidModelResponseError} from "./recognitionErrors";

export const MAX_IMAGE_BYTES = 5 * 1024 * 1024;
export const MAX_BASE64_LENGTH = Math.ceil(MAX_IMAGE_BYTES / 3) * 4;
export const MAX_CATEGORIES = 10;

export type ToyCategory = {
  id: string;
  name: string;
  examples: string | null;
  developmentAspect: string | null;
};

export type RecognitionRequest = {
  imageBase64: string;
  mimeType: "image/jpeg" | "image/png" | "image/webp";
  locale: string;
  categories: ToyCategory[];
};

export type ModelRecognition = {
  status: "ok" | "no_toy" | "multiple_toys" | "person_detected";
  suggestedName: string;
  categoryId: string;
  confidence: number;
  alternativeCategoryIds: string[];
  explanation: string;
  needsReview: boolean;
};

const allowedMimeTypes = new Set([
  "image/jpeg",
  "image/png",
  "image/webp",
]);

const allowedLocales = new Set(["pt-BR", "en-US"]);

const categoryIdPattern = /^[a-z0-9_-]{1,64}$/;

export function parseRecognitionRequest(data: unknown): RecognitionRequest {
  if (!isRecord(data)) {
    throw new Error("invalid_request");
  }

  const imageBase64 = readString(data.imageBase64);
  const mimeType = readString(data.mimeType);
  const locale = readString(data.locale) || "pt-BR";
  if (!imageBase64 || imageBase64.length > MAX_BASE64_LENGTH ||
      !allowedMimeTypes.has(mimeType) || !isCanonicalBase64(imageBase64)) {
    throw new Error("invalid_image");
  }
  if (!allowedLocales.has(locale)) {
    throw new Error("invalid_locale");
  }

  let imageBytes: Buffer;
  try {
    imageBytes = Buffer.from(imageBase64, "base64");
  } catch {
    throw new Error("invalid_image");
  }
  if (imageBytes.length === 0 || imageBytes.length > MAX_IMAGE_BYTES) {
    throw new Error(imageBytes.length > MAX_IMAGE_BYTES ? "image_too_large" : "invalid_image");
  }
  if (imageBytes.toString("base64") !== imageBase64) {
    throw new Error("invalid_image");
  }
  if (!matchesImageSignature(imageBytes, mimeType)) {
    throw new Error("invalid_image");
  }

  if (!Array.isArray(data.categories) || data.categories.length === 0 ||
      data.categories.length > MAX_CATEGORIES) {
    throw new Error("invalid_categories");
  }

  const categories = data.categories.map((value): ToyCategory => {
    if (!isRecord(value)) {
      throw new Error("invalid_categories");
    }
    const id = readString(value.id);
    const name = readString(value.name);
    if (!categoryIdPattern.test(id) || !name || name.length > 100) {
      throw new Error("invalid_categories");
    }
    return {
      id,
      name,
      examples: readNullableString(value.examples, 240),
      developmentAspect: readNullableString(value.developmentAspect, 240),
    };
  });

  const uniqueCategoryIds = new Set(categories.map((category) => category.id));
  if (uniqueCategoryIds.size !== categories.length) {
    throw new Error("invalid_categories");
  }

  return {
    imageBase64,
    mimeType: mimeType as RecognitionRequest["mimeType"],
    locale,
    categories,
  };
}

export function buildRecognitionPrompt(request: RecognitionRequest): string {
  const categoryLines = request.categories.map((category) => {
    const details = [category.examples, category.developmentAspect]
      .filter((value): value is string => Boolean(value))
      .join("; ");
    return `- ${category.id}: ${category.name}${details ? ` (${details})` : ""}`;
  });

  return [
    "Analise a foto para auxiliar um responsável a catalogar um brinquedo.",
    "A imagem deve mostrar um único brinquedo como objeto principal.",
    "Se qualquer pessoa estiver visível, retorne status person_detected e não descreva a pessoa.",
    "Se houver vários brinquedos sem um objeto principal claro, retorne multiple_toys.",
    "Se não houver brinquedo identificável, retorne no_toy.",
    "Para status ok, sugira um nome curto e genérico, sem inventar marca ou modelo.",
    "Escolha exatamente um categoryId da lista e no máximo duas alternativas da mesma lista.",
    "A categoria representa o principal estímulo de brincadeira, não apenas a aparência.",
    `Responda no idioma ${request.locale} e mantenha a explicação em uma frase curta.`,
    "Categorias permitidas:",
    ...categoryLines,
  ].join("\n");
}

export function recognitionJsonSchema(categoryIds: string[]) {
  return {
    type: "object",
    additionalProperties: false,
    required: [
      "status",
      "suggestedName",
      "categoryId",
      "confidence",
      "alternativeCategoryIds",
      "explanation",
      "needsReview",
    ],
    properties: {
      status: {
        type: "string",
        enum: ["ok", "no_toy", "multiple_toys", "person_detected"],
      },
      suggestedName: {type: "string"},
      categoryId: {type: "string", enum: ["", ...categoryIds]},
      confidence: {type: "number", minimum: 0, maximum: 1},
      alternativeCategoryIds: {
        type: "array",
        maxItems: 2,
        items: {type: "string", enum: categoryIds},
      },
      explanation: {type: "string"},
      needsReview: {type: "boolean"},
    },
  } as const;
}

export function validateModelRecognition(
  value: unknown,
  allowedCategoryIds: Set<string>,
): ModelRecognition {
  if (!isRecord(value)) {
    throw new InvalidModelResponseError();
  }
  const status = readString(value.status) as ModelRecognition["status"];
  if (!["ok", "no_toy", "multiple_toys", "person_detected"].includes(status)) {
    throw new InvalidModelResponseError();
  }

  if (status !== "ok") {
    return {
      status,
      suggestedName: "",
      categoryId: "",
      confidence: 0,
      alternativeCategoryIds: [],
      explanation: readString(value.explanation).slice(0, 240),
      needsReview: true,
    };
  }

  const suggestedName = readString(value.suggestedName);
  const categoryId = readString(value.categoryId);
  const rawConfidence = value.confidence;
  const rawAlternatives = value.alternativeCategoryIds;
  const explanation = value.explanation;
  const needsReview = value.needsReview;

  if (!suggestedName || suggestedName.length > 80 ||
      !allowedCategoryIds.has(categoryId) ||
      typeof rawConfidence !== "number" || !Number.isFinite(rawConfidence) ||
      rawConfidence < 0 || rawConfidence > 1 ||
      !Array.isArray(rawAlternatives) || rawAlternatives.length > 2 ||
      typeof explanation !== "string" || explanation.trim().length > 240 ||
      typeof needsReview !== "boolean") {
    throw new InvalidModelResponseError();
  }

  const alternatives = rawAlternatives.map(readString);
  if (alternatives.some((id, index) => !allowedCategoryIds.has(id) ||
      id === categoryId || !id || alternatives.indexOf(id) !== index)) {
    throw new InvalidModelResponseError();
  }

  return {
    status,
    suggestedName,
    categoryId,
    confidence: rawConfidence,
    alternativeCategoryIds: alternatives,
    explanation: explanation.trim(),
    needsReview: needsReview || rawConfidence < 0.75,
  };
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function readString(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

function readNullableString(value: unknown, maxLength: number): string | null {
  const text = readString(value);
  return text ? text.slice(0, maxLength) : null;
}

function isCanonicalBase64(value: string): boolean {
  return value.length % 4 === 0 &&
    /^[A-Za-z0-9+/]+={0,2}$/.test(value) &&
    !value.slice(0, -2).includes("=");
}

function matchesImageSignature(bytes: Buffer, mimeType: string): boolean {
  if (mimeType === "image/jpeg") {
    return bytes.length >= 3 && bytes[0] === 0xff &&
      bytes[1] === 0xd8 && bytes[2] === 0xff;
  }
  if (mimeType === "image/png") {
    return bytes.length >= 8 &&
      bytes.subarray(0, 8).equals(Buffer.from([
        0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a,
      ]));
  }
  if (mimeType === "image/webp") {
    return bytes.length >= 12 &&
      bytes.subarray(0, 4).toString("ascii") === "RIFF" &&
      bytes.subarray(8, 12).toString("ascii") === "WEBP";
  }
  return false;
}
