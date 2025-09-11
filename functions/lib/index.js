"use strict";
/**
 * =================================================================
 * Cloud Functions para App Fitness (con Timeout Extendido)
 * =================================================================
 * Se ha añadido la opción 'timeoutSeconds' para dar más tiempo a las
 * funciones durante el despliegue y evitar el error de timeout.
 */
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.getGeminiAssistance = exports.dailyAgeVerificationCheck = exports.updateUserClaimsOnUpdate = exports.setUserClaimsOnCreate = void 0;
// Importaciones de Firebase Functions v2 y Admin SDK
const v2_1 = require("firebase-functions/v2");
const firestore_1 = require("firebase-functions/v2/firestore");
const scheduler_1 = require("firebase-functions/v2/scheduler");
const admin = __importStar(require("firebase-admin"));
// La importación de GoogleGenerativeAI se ha movido adentro de la función.
// Inicializa el SDK de Admin, que es ligero y puede permanecer aquí.
admin.initializeApp();
const db = admin.firestore();
const auth = admin.auth();
// --- Opciones de Runtime para las funciones ---
// Definimos las opciones aquí para reutilizarlas y mantener el código limpio.
const functionOptions = {
    region: "us-central1", // Región que corresponde a nam5
    memory: "512MiB", // Asignamos más memoria
    cpu: 1, // Asignamos una CPU completa
    // --- CORRECCIÓN CLAVE: Aumentamos el tiempo de espera ---
    timeoutSeconds: 120,
};
/**
 * -----------------------------------------------------------------
 * FUNCIÓN AUXILIAR #1: Calcular Edad
 * -----------------------------------------------------------------
 */
function calculateAge(birthDate) {
    if (!birthDate)
        return 0;
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const m = today.getMonth() - birthDate.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
        age--;
    }
    return age;
}
/**
 * -----------------------------------------------------------------
 * FUNCIÓN AUXILIAR #2: Lógica centralizada para establecer Claims
 * -----------------------------------------------------------------
 */
async function updateUserAuthClaims(userId, dob, needsVerificationInitial) {
    try {
        const age = calculateAge(dob);
        const isOfAge = age >= 18;
        const needsVerification = isOfAge && (needsVerificationInitial || false);
        console.log(`Actualizando claims para ${userId}: { age: ${age}, isOfAge: ${isOfAge}, needsVerification: ${needsVerification} }`);
        await auth.setCustomUserClaims(userId, {
            isOfAge: isOfAge,
            needsVerification: needsVerification,
        });
    }
    catch (error) {
        console.error(`Error al establecer los custom claims para el usuario ${userId}`, error);
    }
}
/**
 * -----------------------------------------------------------------
 * FUNCIONES DE USUARIO (on-create y on-update)
 * -----------------------------------------------------------------
 */
exports.setUserClaimsOnCreate = (0, firestore_1.onDocumentCreated)({
    document: "users/{userId}",
    ...functionOptions // Aplicamos las opciones de recursos
}, async (event) => {
    var _a;
    const userDoc = (_a = event.data) === null || _a === void 0 ? void 0 : _a.data();
    if (!userDoc)
        return;
    const { dateOfBirth, needsAgeVerification, displayName, photoURL } = userDoc;
    await updateUserAuthClaims(event.params.userId, dateOfBirth.toDate(), needsAgeVerification);
    await auth.updateUser(event.params.userId, { displayName, photoURL });
});
exports.updateUserClaimsOnUpdate = (0, firestore_1.onDocumentUpdated)({
    document: "users/{userId}",
    ...functionOptions // Aplicamos las opciones de recursos
}, async (event) => {
    if (!event.data)
        return;
    const afterData = event.data.after.data();
    const beforeData = event.data.before.data();
    const dobChanged = !afterData.dateOfBirth.isEqual(beforeData.dateOfBirth);
    const verificationChanged = afterData.needsAgeVerification !== beforeData.needsAgeVerification;
    if (!dobChanged && !verificationChanged)
        return;
    await updateUserAuthClaims(event.params.userId, afterData.dateOfBirth.toDate(), afterData.needsAgeVerification);
});
/**
 * -----------------------------------------------------------------
 * FUNCIÓN PROGRAMADA DIARIA
 * -----------------------------------------------------------------
 */
exports.dailyAgeVerificationCheck = (0, scheduler_1.onSchedule)({
    schedule: "every 24 hours",
    ...functionOptions // Aplicamos las opciones de recursos
}, async (context) => {
    console.log("Ejecutando la verificación diaria de edad...");
    const today = new Date();
    const eighteenYearsAgo = new Date(today.getFullYear() - 18, today.getMonth(), today.getDate());
    const startOfToday = new Date(eighteenYearsAgo);
    startOfToday.setHours(0, 0, 0, 0);
    const endOfToday = new Date(eighteenYearsAgo);
    endOfToday.setHours(23, 59, 59, 999);
    const usersTurning18Query = db.collection("users").where("dateOfBirth", ">=", startOfToday).where("dateOfBirth", "<=", endOfToday);
    const snapshot = await usersTurning18Query.get();
    if (snapshot.empty)
        return;
    const batch = db.batch();
    snapshot.forEach(doc => {
        const userRef = db.collection("users").doc(doc.id);
        batch.update(userRef, { needsAgeVerification: true });
    });
    await batch.commit();
    console.log(`Se marcaron ${snapshot.size} usuarios para verificación de edad.`);
});
/**
 * -----------------------------------------------------------------
 * FUNCIÓN PARA GEMINI (CON IMPORTACIÓN DINÁMICA)
 * -----------------------------------------------------------------
 */
exports.getGeminiAssistance = v2_1.https.onCall(functionOptions, async (request) => {
    if (!request.auth) {
        throw new v2_1.https.HttpsError("unauthenticated", "Debes estar autenticado para usar el asistente.");
    }
    const GEMINI_API_KEY = process.env.GEMINI_KEY;
    if (!GEMINI_API_KEY) {
        console.error("API Key de Gemini no configurada.");
        throw new v2_1.https.HttpsError("failed-precondition", "La función de asistente no está disponible en este momento.");
    }
    //comentario random
    const { GoogleGenerativeAI } = await Promise.resolve().then(() => __importStar(require("@google/generative-ai")));
    const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);
    const { prompt, type, history } = request.data;
    if (!prompt || !type) {
        throw new v2_1.https.HttpsError("invalid-argument", "Los campos 'prompt' y 'type' son requeridos.");
    }
    const systemInstruction = type === 'nutrition'
        ? "Quiero que actúes como un Dietista-Nutricionista clínico con certificación, especializado en la creación de planes de alimentación personalizados basados en la evidencia científica. Tu tarea es seguir rigurosamente el Proceso de Atención Nutricional (PAN) para crear un plan de alimentación detallado, seguro y altamente personalizado para mí."
        : "Actúa como un Especialista Certificado en Fuerza y Acondicionamiento (CSCS) con un Doctorado (PhD) en Fisiología del Ejercicio. Posees 15 años de experiencia diseñando programas de entrenamiento basados en la evidencia científica para una clientela diversa, que incluye tanto atletas de élite como población general. Tus principios fundamentales son la seguridad, la progresión a largo plazo, la individualización y la adherencia del cliente.";
    const model = genAI.getGenerativeModel({ model: "gemini-pro", systemInstruction: systemInstruction });
    const chat = model.startChat({ history: history || [] });
    try {
        const result = await chat.sendMessage(prompt);
        return { response: result.response.text() };
    }
    catch (error) {
        console.error("Error al llamar a la API de Gemini:", error);
        throw new v2_1.https.HttpsError("internal", "No se pudo obtener una respuesta del asistente.");
    }
});
//# sourceMappingURL=index.js.map