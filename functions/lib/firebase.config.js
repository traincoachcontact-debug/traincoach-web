"use strict";
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
Object.defineProperty(exports, "__esModule", { value: true });
exports.app = void 0;
// 1. Importa la función de inicialización
const app_1 = require("firebase/app");
// 2. Pega aquí tu objeto de configuración de Firebase
//    Puedes encontrarlo en tu Consola de Firebase:
//    - Ve a "Configuración del proyecto" (el ícono de engranaje).
//    - En la pestaña "General", baja hasta "Tus apps".
//    - Selecciona tu aplicación web (si no tienes una, créala).
//    - En "SDK de Firebase", elige la opción "Configuración" (Config).
//    - Copia el objeto 'firebaseConfig' y pégalo aquí.
const firebaseConfig = {
    apiKey: "AIzaSyAEbvgpdnmEDCMu4MlAZNN0kASWyFeg-ng",
    authDomain: "traincoach-2ef9d.firebaseapp.com",
    projectId: "traincoach-2ef9d",
    storageBucket: "traincoach-2ef9d.firebasestorage.app",
    messagingSenderId: "132564343334",
    appId: "1:132564343334:web:f22c6aac4949f74444a4e7",
};
// 3. Inicializa Firebase con tu configuración
const app = (0, app_1.initializeApp)(firebaseConfig);
exports.app = app;
//# sourceMappingURL=firebase.config.js.map