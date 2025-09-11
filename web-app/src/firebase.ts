import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyAEbvgpdnmEDCMu4MlAZNN0kASWyFeg-ng",
  authDomain: "traincoach-2ef9d.firebaseapp.com",
  projectId: "traincoach-2ef9d",
  storageBucket: "traincoach-2ef9d.firebasestorage.app",
  messagingSenderId: "132564343334",
  appId: "1:132564343334:web:a870c4de131e57b144a4e7",
  measurementId: "G-SWFLDQ6GLR"
};

export const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
