import * as functions from "firebase-functions/v2";
import { https } from "firebase-functions/v2";
import * as admin from "firebase-admin";
import { defineSecret } from "firebase-functions/params";
import { GoogleGenerativeAI } from "@google/generative-ai";

// Inicialización de Firebase Admin. Se llama una sola vez cuando
// la función se "despierta" por primera vez (cold start).
admin.initializeApp();

// Opciones de configuración para la función
const functionOptions = {
  region: "us-central1",
  memory: "512MiB" as const,
  cpu: 1 as const,
  timeoutSeconds: 240,
};

// Secreto para la API Key de Gemini
const geminiApiKey = defineSecret("GEMINI_KEY");

// Función principal
export const getGeminiAssistance = https.onCall(
  {
    ...functionOptions,
    secrets: [geminiApiKey],
    enforceAppCheck: true,
  },
  async (request) => {
    // 1. Verificación de seguridad
    if (!request.app) {
      throw new https.HttpsError(
        "failed-precondition",
        "La función debe ser llamada desde una app con App Check verificado."
      );
    }
    if (!request.auth) {
      throw new https.HttpsError(
        "unauthenticated",
        "Debes estar autenticado para usar el asistente."
      );
    }

    // 2. Cargar la API Key del Secret Manager
    const GEMINI_API_KEY = process.env.GEMINI_KEY;
    if (!GEMINI_API_KEY) {
      console.error("CRITICAL: La variable de entorno GEMINI_KEY no fue encontrada.");
      throw new https.HttpsError(
        "failed-precondition",
        "La función de asistente no está disponible en este momento."
      );
    }

    // 3. Validar los datos de entrada
    const { prompt, type, history } = request.data;
    if (!prompt || !type) {
      throw new https.HttpsError(
        "invalid-argument",
        "Los campos 'prompt' y 'type' son requeridos."
      );
    }

    // 4. Inicializar el cliente de IA
    const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);

    // 5. Configurar el asistente según el tipo
    let systemInstruction = "";
    switch (type) {
      case "nutrition":
        systemInstruction =
          "Actúa como un asistente nutricional experto. Proporciona consejos claros, seguros y basados en evidencia. No des diagnósticos médicos. Siempre sugiere consultar a un profesional.";
        break;
      case "gym_assistant":
        systemInstruction =
          "Actúa como un entrenador de gimnasio profesional y amigable. Ofrece consejos sobre rutinas, ejercicios y buena forma. Prioriza la seguridad y recomienda calentar antes de entrenar.";
        break;
      case "progress":
        systemInstruction = 
          "Actúa como un coach de progreso motivacional. Analiza datos de entrenamiento y ofrece ánimo y consejos para mejorar. Sé positivo y enfócate en la consistencia.";
        break;
      default:
        throw new https.HttpsError(
          "invalid-argument",
          "Tipo de asistente no válido."
        );
    }

    const model = genAI.getGenerativeModel({
      model: "gemini-1.5-flash-001",
      systemInstruction: { role: "model", parts: [{ text: systemInstruction }] },
    });

    const chat = model.startChat({ history: history || [] });

    // 6. Enviar la solicitud a Gemini
    try {
      const result = await chat.sendMessage(prompt);
      return { response: result.response.text() };
    } catch (error) {
      console.error("Error al llamar a la API de Gemini:", error);
      throw new https.HttpsError(
        "internal",
        "No se pudo obtener una respuesta del asistente."
        //p1.1
      );
    }
  }
);
