/**
 * =================================================================
 * Archivo de Configuración de Firebase
 * =================================================================
 * Este archivo inicializa tu aplicación de Firebase con las credenciales
 * de tu proyecto. Es fundamental para que cualquier servicio de Firebase
 * (Auth, Firestore, etc.) funcione en tu app.
 *
 * Coloca este archivo en la raíz de tu carpeta `src` o en una
 * carpeta de configuración (ej: `src/config/firebase.config.ts`).
 */
declare const app: import("@firebase/app").FirebaseApp;
export { app };
