import { db } from "../firebase";
import {
  collection,
  addDoc,
  query,
  orderBy,
  getDocs,
  Timestamp,
} from "firebase/firestore";

// ---------------- TIPOS ----------------

type Maybe<T> = T | null | undefined;

export type UserProfile = {
  age?: number;
  sex?: string;
  heightCm?: number;
  peso?: number;
  allergies?: string[];
  dislikes?: string[];
  diseases?: string[];
  medications?: string[];
  activityLevel?: string;
  goals?: string[];
  schedule?: string;
  XP?: string;
  daysPerWeek?: number;
  injuries?: string[];
};

export type ChatMessage = {
  role: "user" | "assistant" | "system";
  content: string;
  createdAt?: Date;
};

// ---------------- GEMINI CONFIG ----------------

const API_KEY = import.meta.env.VITE_GEMINI_API_KEY as string;
const MODEL_ID =
  (import.meta.env.VITE_GEMINI_MODEL_ID as string) || "gemini-1.5-pro";

const BASE_URL = `https://generativelanguage.googleapis.com/v1/models/${MODEL_ID}:generateContent?key=${API_KEY}`;

// ---------------- UTILIDADES ----------------

function assertApiKey() {
  if (!API_KEY) {
    throw new Error(
      "Falta VITE_GEMINI_API_KEY en .env.local. Añádela y reinicia el dev server."
    );
  }
}

function joinPartsText(data: any): string {
  return (
    data?.candidates?.[0]?.content?.parts?.map((p: any) => p?.text).join("") ||
    data?.candidates?.[0]?.content?.parts?.[0]?.text ||
    ""
  );
}

function kv(label: string, v: Maybe<string | number>): string {
  return v !== null && v !== undefined && `${String(v)}`.trim() !== ""
    ? `- ${label}: ${v}\n`
    : "";
}

function list(label: string, arr?: string[]): string {
  return arr && arr.length ? `- ${label}: ${arr.join(", ")}\n` : "";
}

function profileToBullets(p?: Partial<UserProfile>): string {
  if (!p) return "";
  return (
    kv("Edad", p.age) +
    kv("Sexo", p.sex) +
    kv("Altura (cm)", p.heightCm) +
    kv("Peso (kg)", p.peso) +
    kv("Nivel de actividad", p.activityLevel) +
    list("Objetivos", p.goals) +
    kv("Horarios/Rutina diaria", p.schedule) +
    list("Alergias", p.allergies) +
    list("Alimentos que no le gustan", p.dislikes) +
    list("Enfermedades/diagnósticos", p.diseases) +
    list("Medicaciones", p.medications) +
    kv("Experiencia en gimnasio", p.XP) +
    kv("Días por semana (entreno)", p.daysPerWeek) +
    list("Lesiones/dolores", p.injuries)
  ).trim();
}

// ---------------- PROMPTS ----------------

const SAFETY_FOOTER =
  "\n\n⚠️ Aviso: No soy profesional médico. Consulta a un médico/fisioterapeuta antes de iniciar cambios de ejercicio o alimentación, especialmente si tienes condiciones preexistentes.";

function nutritionSystemPrompt(userBullets: string, userFreeText?: string) {
  return `Actúa como "NutriCoach": nutricionista profesional basado en evidencia.
Datos del usuario:
${userBullets || "- (no aportados)"}${userFreeText ? `\n- Nota libre: ${userFreeText}` : ""}

Entrega en Markdown, breve y accionable.
${SAFETY_FOOTER}`;
}

function routineSystemPrompt(userBullets: string, userFreeText?: string) {
  return `Actúa como "Coach Pro": entrenador personal experto, motivador y empático.
Datos del usuario:
${userBullets || "- (no aportados)"}${userFreeText ? `\n- Nota libre: ${userFreeText}` : ""}

Entrega en Markdown, claro y conciso.
${SAFETY_FOOTER}`;
}

// ---------------- FIRESTORE ----------------

export async function saveMessageToFirestore(
  userId: string,
  message: ChatMessage
): Promise<void> {
  await addDoc(collection(db, "users", userId, "chatHistory"), {
    role: message.role,
    content: message.content,
    createdAt: Timestamp.now(),
  });
}

export async function loadChatHistoryFromFirestore(
  userId: string
): Promise<ChatMessage[]> {
  const q = query(
    collection(db, "users", userId, "chatHistory"),
    orderBy("createdAt", "asc")
  );
  const snapshot = await getDocs(q);
  return snapshot.docs.map((doc) => ({
    role: doc.data().role,
    content: doc.data().content,
    createdAt: (doc.data().createdAt as Timestamp)?.toDate(),
  })) as ChatMessage[];
}

// ---------------- CHAT / AI ----------------

let chatHistory: ChatMessage[] = [
  { role: "system", content: "Eres un asistente de nutrición y rutinas." },
];

export function resetChatHistory() {
  chatHistory = [
    { role: "system", content: "Eres un asistente de nutrición y rutinas." },
  ];
}

export async function chatWithGemini(
  userInput: string,
  userId: string
): Promise<string> {
  assertApiKey();

  const userMsg: ChatMessage = { role: "user", content: userInput };
  chatHistory.push(userMsg);
  await saveMessageToFirestore(userId, userMsg);

  const res = await fetch(BASE_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      generationConfig: {
        temperature: 0.6,
        topP: 0.9,
        maxOutputTokens: 2048,
      },
      contents: chatHistory.map((m) => ({
        role: m.role === "assistant" ? "model" : "user",
        parts: [{ text: m.content }],
      })),
    }),
  });

  if (!res.ok) {
    const txt = await res.text().catch(() => "");
    throw new Error(`HTTP ${res.status} ${res.statusText} — ${txt}`);
  }

  const data = await res.json();
  const text = joinPartsText(data);

  if (!text) throw new Error("Respuesta vacía de Gemini.");

  const assistantMsg: ChatMessage = { role: "assistant", content: text };
  chatHistory.push(assistantMsg);
  await saveMessageToFirestore(userId, assistantMsg);

  return text;
}

// ---------------- EXPORTS PÚBLICOS ----------------

export async function askGemini(prompt: string): Promise<string> {
  return generateSingleShot(prompt);
}

export async function getNutritionPlan(
  input: string,
  profile?: Partial<UserProfile>
): Promise<string> {
  const bullets = profileToBullets(profile);
  const prompt = nutritionSystemPrompt(bullets, input?.trim() || undefined);
  return generateSingleShot(prompt);
}

export async function getRoutinePlan(
  input: string,
  profile?: Partial<UserProfile>
): Promise<string> {
  const bullets = profileToBullets(profile);
  const prompt = routineSystemPrompt(bullets, input?.trim() || undefined);
  return generateSingleShot(prompt);
}

async function generateSingleShot(prompt: string): Promise<string> {
  assertApiKey();
  const res = await fetch(BASE_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      generationConfig: {
        temperature: 0.6,
        topP: 0.9,
        maxOutputTokens: 2048,
      },
      contents: [{ parts: [{ text: prompt }] }],
    }),
  });

  if (!res.ok) {
    const txt = await res.text().catch(() => "");
    throw new Error(`HTTP ${res.status} ${res.statusText} — ${txt}`);
  }
  const data = await res.json();
  const text = joinPartsText(data);
  if (!text) throw new Error("Respuesta vacía de Gemini.");
  return text;
}

const aiService = {
  askGemini,
  getNutritionPlan,
  getRoutinePlan,
  chatWithGemini,
  resetChatHistory,
  saveMessageToFirestore,
  loadChatHistoryFromFirestore,
};

export default aiService;
