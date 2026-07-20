import {defineSecret} from "firebase-functions/params";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import OpenAI from "openai";

import {
  buildRecognitionPrompt,
  parseRecognitionRequest,
  recognitionJsonSchema,
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
    const client = new OpenAI({apiKey: openAiApiKey.value()});

    try {
      const response = await client.responses.create({
        model: process.env.OPENAI_VISION_MODEL ?? "gpt-5-mini",
        store: false,
        max_output_tokens: 400,
        input: [
          {
            role: "user",
            content: [
              {type: "input_text", text: buildRecognitionPrompt(input)},
              {
                type: "input_image",
                detail: "low",
                image_url: `data:${input.mimeType};base64,${input.imageBase64}`,
              },
            ],
          },
        ],
        text: {
          format: {
            type: "json_schema",
            name: "toy_recognition",
            strict: true,
            schema: recognitionJsonSchema(categoryIds),
          },
        },
      });

      if (!response.output_text) {
        throw new Error("empty_model_response");
      }
      const parsed = validateModelRecognition(
        JSON.parse(response.output_text),
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
        modelVersion: process.env.OPENAI_VISION_MODEL ?? "gpt-5-mini",
      };
    } catch (error) {
      if (error instanceof HttpsError) throw error;
      console.error("recognizeToy failed", {
        type: error instanceof Error ? error.name : "unknown",
      });
      throw new HttpsError(
        "unavailable",
        "O reconhecimento está temporariamente indisponível.",
      );
    }
  },
);
