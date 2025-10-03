// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyAEbvgpdnmEDCMu4MlAZNN0kASWyFeg-ng",
  authDomain: "traincoach-2ef9d.firebaseapp.com",
  projectId: "traincoach-2ef9d",
  storageBucket: "traincoach-2ef9d.firebasestorage.app",
  messagingSenderId: "132564343334",
  appId: "1:132564343334:web:a870c4de131e57b144a4e7",
  measurementId: "G-SWFLDQ6GLR"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);