// src/screens/RoutineAssistantScreen.tsx
import React, { useEffect, useState } from "react";
import aiService from "../services/aiService"; // usamos el objeto default
import type { ChatMessage, UserProfile } from "../services/aiService";
import { useAuth } from "../contexts/AuthContext";

const RoutineAssistantScreen: React.FC = () => {
  const { user } = useAuth();

  // perfil base (puedes vincularlo al perfil real del user en Firestore si quieres)
  const [profile, setProfile] = useState<Partial<UserProfile>>({
    age: 25,
    sex: "masculino",
    heightCm: 180,
    peso: 78,
    activityLevel: "Moderado",
    goals: ["ganar músculo"],
  });

  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);

  // cargar historial guardado en Firestore
  useEffect(() => {
    const load = async () => {
      if (!user) return;
      const history = await aiService.loadChatHistoryFromFirestore(user.uid);
      setMessages(history);
    };
    load();
  }, [user]);

  const handleSend = async () => {
    if (!user || !input.trim()) return;
    setLoading(true);

    const userMsg: ChatMessage = { role: "user", content: input };
    setMessages((prev) => [...prev, userMsg]);

    try {
      const reply = await aiService.chatWithGemini(input, user.uid);
      const aiMsg: ChatMessage = { role: "assistant", content: reply };
      setMessages((prev) => [...prev, aiMsg]);
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
    <div className="p-6 max-w-3xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">🏋️ Asistente de Rutinas</h1>
        <button
          onClick={handleNewChat}
          className="text-sm px-3 py-1 rounded bg-gray-200 hover:bg-gray-300"
        >
          Nueva conversación
        </button>
      </div>

      {/* perfil editable */}
      <div className="grid gap-3 bg-gray-50 p-4 rounded-xl shadow">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <label className="font-semibold">Edad</label>
          <input
            type="number"
            value={profile.age ?? ""}
            onChange={(e) => setProfile({ ...profile, age: Number(e.target.value) })}
            className="border rounded p-2"
          />

          <label className="font-semibold">Sexo</label>
          <select
            value={profile.sex ?? ""}
            onChange={(e) => setProfile({ ...profile, sex: e.target.value })}
            className="border rounded p-2"
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
            className="border rounded p-2"
          />

          <label className="font-semibold">Peso (kg)</label>
          <input
            type="number"
            value={profile.peso ?? ""}
            onChange={(e) => setProfile({ ...profile, peso: Number(e.target.value) })}
            className="border rounded p-2"
          />

          <label className="font-semibold">Nivel de actividad</label>
          <input
            type="text"
            value={profile.activityLevel ?? ""}
            onChange={(e) => setProfile({ ...profile, activityLevel: e.target.value })}
            className="border rounded p-2"
          />

          <label className="font-semibold">Objetivo</label>
          <input
            type="text"
            value={profile.goals?.[0] ?? ""}
            onChange={(e) => setProfile({ ...profile, goals: [e.target.value] })}
            className="border rounded p-2"
          />
        </div>

        <div>
          <button
            className="text-sm px-3 py-1 rounded bg-indigo-600 text-white hover:bg-indigo-700"
            disabled={loading || !user}
            onClick={async () => {
              if (!user) return;
              setLoading(true);
              try {
                const plan = await aiService.getRoutinePlan(
                  "Genera una rutina de 3 días con ejercicios variados.",
                  profile
                );
                const aiMsg: ChatMessage = { role: "assistant", content: plan };
                setMessages((prev) => [...prev, aiMsg]);
                await aiService.saveMessageToFirestore(user.uid, aiMsg);
              } catch (e) {
                console.error(e);
              } finally {
                setLoading(false);
              }
            }}
          >
            Generar rutina con mi perfil
          </button>
        </div>
      </div>

      {/* chat */}
      <div className="border rounded-lg p-4 h-96 overflow-y-auto bg-white">
        {messages.map((m, i) => (
          <div
            key={i}
            className={`mb-2 p-2 rounded-lg ${
              m.role === "assistant"
                ? "bg-indigo-100 text-indigo-900"
                : m.role === "system"
                ? "bg-gray-100 text-gray-700"
                : "bg-blue-100 text-blue-900"
            }`}
          >
            <strong>
              {m.role === "assistant" ? "IA" : m.role === "system" ? "Sistema" : "Tú"}:
            </strong>{" "}
            {m.content}
          </div>
        ))}
      </div>

      {/* input */}
      <div className="flex gap-2">
        <textarea
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="Escribe aquí tus dudas o cambios (p. ej., 'no puedo hacer sentadillas por lesión')…"
          className="w-full border rounded-lg p-2"
          rows={3}
          disabled={loading || !user}
        />
        <button
          onClick={handleSend}
          disabled={loading || !user}
          className="self-start bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-lg"
        >
          {loading ? "Enviando…" : "Enviar"}
        </button>
      </div>
    </div>
  );
};

export default RoutineAssistantScreen;
