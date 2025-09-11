import axios from "axios";

const GEMINI_API_KEY = "AIzaSyDc0uVtsEgamU_YOezC7y7nVMs5LQYvbrY";
const GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent";

export async function askGemini(prompt: string) {
  try {
    const res = await axios.post(
      `${GEMINI_URL}?key=${GEMINI_API_KEY}`,
      {
        contents: [{ parts: [{ text: prompt }] }]
      },
      { headers: { "Content-Type": "application/json" } }
    );
    return res.data.candidates?.[0]?.content?.parts?.[0]?.text || "Sin respuesta";
  } catch (err) {
    console.error(err);
    return "Error en la consulta a Gemini";
  }
}
