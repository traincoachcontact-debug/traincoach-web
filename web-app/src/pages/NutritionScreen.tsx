// src/screens/NutritionScreen.tsx
import React, { useEffect, useRef, useState } from "react";
import aiService from "../services/aiService";
import type { ChatMessage, UserProfile } from "../services/aiService";
import { useAuth } from "../contexts/AuthContext";

const NutritionScreen: React.FC = () => {
  const { user } = useAuth();

  const [profile, setProfile] = useState<Partial<UserProfile>>({
    age: 22,
    sex: "masculino",
    heightCm: 180,
    peso: 90,
    activityLevel: "Moderado",
    goals: ["Regresar a mi peso ideal"],
  });

  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);

  // referencia para autoscroll
  const bottomRef = useRef<HTMLDivElement | null>(null);

  // Cargar historial desde Firestore
  useEffect(() => {
    const load = async () => {
      if (!user) return;
      const history = await aiService.loadChatHistoryFromFirestore(user.uid);
      setMessages(history);
    };
    load();
  }, [user]);

  // Autoscroll cada vez que cambia messages
  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const handleSend = async () => {
    if (!user || !input.trim()) return;
    setLoading(true);

    const userMsg: ChatMessage = { role: "user", content: input };
    setMessages((prev) => [...prev, userMsg]);

    try {
      const reply = await aiService.chatWithGemini(input, user.uid);
      const aiMsg: ChatMessage = { role: "assistant", content: reply };
      setMessages((prev) => [...prev, aiMsg]);
      await aiService.saveMessageToFirestore(user.uid, aiMsg);
    } catch (e) {
      console.error(e);
      setMessages((prev) => [
        ...prev,
        { role: "assistant", content: "⚠️ Ocurrió un error generando la respuesta." },
      ]);
    } finally {
      setInput("");
      setLoading(false);
    }
  };

  const handleNewChat = () => {
    aiService.resetChatHistory();
    setMessages((prev) => prev.filter((m) => m.role === "system"));
  };

  return (
    <div className="p-6 max-w-3xl mx-auto h-screen flex flex-col">
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <h1 className="text-2xl font-bold">🍎 Asistente de Nutrición</h1>
        <button
          onClick={handleNewChat}
          className="text-black px-3 py-1 rounded bg-gray-300 hover:bg-gray-400"
        >
          Nueva conversación
        </button>
      </div>

      {/* Perfil */}
      <div className="grid gap-3 bg-gray-500 p-4 rounded-xl shadow mb-4">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <label className="font-semibold">Edad</label>
          <input
            type="number"
            value={profile.age ?? ""}
            onChange={(e) => setProfile({ ...profile, age: Number(e.target.value) })}
            className="border rounded p-2 text-white"
          />

          <label className="font-semibold">Sexo</label>
          <select
            value={profile.sex ?? ""}
            onChange={(e) => setProfile({ ...profile, sex: e.target.value })}
            className="border rounded p-2 text-white"
          >
            <option value="">Seleccionar</option>
            <option value="masculino">Masculino</option>
            <option value="femenino">Femenino</option>
            <option value="otro">Otro</option>
          </select>

          <label className="font-semibold">Altura (cm)</label>
          <input
            type="number"
            value={profile.heightCm ?? ""}
            onChange={(e) => setProfile({ ...profile, heightCm: Number(e.target.value) })}
            className="border rounded p-2 text-white"
          />

          <label className="font-semibold">Peso (kg)</label>
          <input
            type="number"
            value={profile.peso ?? ""}
            onChange={(e) => setProfile({ ...profile, peso: Number(e.target.value) })}
            className="border rounded p-2 text-white"
          />

          <label className="font-semibold">Nivel de actividad</label>
          <input
            type="text"
            value={profile.activityLevel ?? ""}
            onChange={(e) => setProfile({ ...profile, activityLevel: e.target.value })}
            className="border rounded p-2 text-white"
          />

          <label className="font-semibold">Objetivo</label>
          <input
            type="text"
            value={profile.goals?.[0] ?? ""}
            onChange={(e) => setProfile({ ...profile, goals: [e.target.value] })}
            className="border rounded p-2 text-white"
          />
        </div>

        <div>
          <button
            className="text-sm px-3 py-1 rounded bg-green-600 text-white hover:bg-green-700"
            disabled={loading || !user}
            onClick={async () => {
              if (!user) return;
              setLoading(true);
              try {
                const plan = await aiService.getNutritionPlan(
                  "Genera un plan de 1 día con intercambios.",
                  profile
                );
                const aiMsg: ChatMessage = { role: "assistant", content: plan };
                setMessages((prev) => [...prev, aiMsg]);
                await aiService.saveMessageToFirestore(user.uid, aiMsg);
              } catch (e) {
                console.error(e);
                setMessages((prev) => [
                  ...prev,
                  { role: "assistant", content: "⚠️ Error generando el plan." },
                ]);
              } finally {
                setLoading(false);
              }
            }}
          >
            Generar plan con mi perfil
          </button>
        </div>
      </div>

      {/* Chat con autoscroll */}
      <div className="flex-grow border rounded-lg p-4 overflow-y-auto bg-gray-500 text-white mb-4">
        {messages.map((m, i) => (
          <div
            key={i}
            className={`mb-2 p-2 rounded-lg ${
              m.role === "assistant"
                ? "bg-green-100 text-green-900"
                : m.role === "system"
                ? "bg-gray-100 text-gray-700"
                : "bg-blue-100 text-blue-900"
            }`}
          >
            <strong>
              {m.role === "assistant"
                ? "IA"
                : m.role === "system"
                ? "Sistema"
                : "Tú"}
              :
            </strong>{" "}
            {m.content}
          </div>
        ))}
        <div ref={bottomRef} /> {/* Scroll automático */}
      </div>

      {/* Input */}
      <div className="flex gap-2">
        <textarea
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="Escribe aquí tus dudas o cambios (p. ej., 'soy alérgico a los frutos secos')…"
          className="w-full border rounded-lg p-2 text-white"
          rows={3}
          disabled={loading || !user}
        />
        <button
          onClick={handleSend}
          disabled={loading || !user}
          className="self-start bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg"
        >
          {loading ? "Enviando…" : "Enviar"}
        </button>
      </div>
    </div>
  );
};

export default NutritionScreen;
