/**
 * =================================================================
 * Cloud Functions para App Fitness (con Timeout Extendido)
 * =================================================================
 * Se ha añadido la opción 'timeoutSeconds' para dar más tiempo a las
 * funciones durante el despliegue y evitar el error de timeout.
 */
import { https } from "firebase-functions/v2";
/**
 * -----------------------------------------------------------------
 * FUNCIONES DE USUARIO (on-create y on-update)
 * -----------------------------------------------------------------
 */
export declare const setUserClaimsOnCreate: import("firebase-functions/core").CloudFunction<import("firebase-functions/v2/firestore").FirestoreEvent<import("firebase-functions/v2/firestore").QueryDocumentSnapshot | undefined, {
    userId: string;
}>>;
export declare const updateUserClaimsOnUpdate: import("firebase-functions/core").CloudFunction<import("firebase-functions/v2/firestore").FirestoreEvent<import("firebase-functions/v2").Change<import("firebase-functions/v2/firestore").QueryDocumentSnapshot> | undefined, {
    userId: string;
}>>;
/**
 * -----------------------------------------------------------------
 * FUNCIÓN PROGRAMADA DIARIA
 * -----------------------------------------------------------------
 */
export declare const dailyAgeVerificationCheck: import("firebase-functions/v2/scheduler").ScheduleFunction;
/**
 * -----------------------------------------------------------------
 * FUNCIÓN PARA GEMINI (CON IMPORTACIÓN DINÁMICA)
 * -----------------------------------------------------------------
 */
export declare const getGeminiAssistance: https.CallableFunction<any, Promise<{
    response: string;
}>, unknown>;
