import {randomUUID} from "node:crypto";

import {defineSecret} from "firebase-functions/params";
import {logger} from "firebase-functions/logger";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import OpenAI from "openai";

import {
  assertModelResponseHasOutputText,
  classifyRecognitionError,
  InvalidModelResponseError,
  writeRecognitionFailureLog,
} from "./recognitionErrors";
import {
  createToyRecognitionResponse,
  parseRecognitionRequest,
  validateModelRecognition,
} from "./toyRecognition";

const openAiApiKey = defineSecret("OPENAI_API_KEY");

export const recognizeToy = onCall(
  {
    region: "southamerica-east1",
    timeoutSeconds: 60,
    memory: "512MiB",
    maxInstances: 10,
    enforceAppCheck: true,
    secrets: [openAiApiKey],
  },
  async (request) => {
    const correlationId = randomUUID();
    let input;
    try {
      input = parseRecognitionRequest(request.data);
    } catch (error) {
      const reason = error instanceof Error ? error.message : "invalid_request";
      throw new HttpsError(
        reason === "image_too_large" ? "resource-exhausted" : "invalid-argument",
        "A solicitação de reconhecimento é inválida.",
        {reason},
      );
    }

    const categoryIds = input.categories.map((category) => category.id);
    const model = process.env.OPENAI_VISION_MODEL ?? "gpt-5-mini";
    const client = new OpenAI({apiKey: openAiApiKey.value()});

    try {
      const response = await createToyRecognitionResponse(
        client.responses,
        model,
        input,
        categoryIds,
      );

      assertModelResponseHasOutputText(response);
      let modelOutput: unknown;
      try {
        modelOutput = JSON.parse(response.output_text);
      } catch {
        throw new InvalidModelResponseError();
      }
      const parsed = validateModelRecognition(
        modelOutput,
        new Set(categoryIds),
      );

      if (parsed.status !== "ok") {
        throw new HttpsError(
          "failed-precondition",
          "A foto não atende aos requisitos do reconhecimento.",
          {reason: parsed.status},
        );
      }

      return {
        suggestedName: parsed.suggestedName,
        categoryId: parsed.categoryId,
        confidence: parsed.confidence,
        alternativeCategoryIds: parsed.alternativeCategoryIds,
        explanation: parsed.explanation,
        needsReview: parsed.needsReview,
        modelVersion: model,
      };
    } catch (error) {
      if (error instanceof HttpsError) throw error;
      const classification = classifyRecognitionError(error);
      writeRecognitionFailureLog(
        logger.write,
        correlationId,
        classification,
      );
      throw new HttpsError(
        classification.httpsCode,
        classification.httpsCode === "unavailable" ||
          classification.httpsCode === "resource-exhausted" ?
          "O reconhecimento está temporariamente indisponível." :
          "Não foi possível processar o reconhecimento.",
      );
    }
  },
);
