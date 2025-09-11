// src/pages/ProgressAssistantScreen.tsx
import { useEffect, useState } from "react";
import { doc, getDoc } from "firebase/firestore";
import { db } from "../services/firebase.config";
import { useAuth } from "../contexts/AuthContext";

type NutritionPlan = { meals: { time: string; description: string }[] };
type RoutinePlan = { exercises: { time: string; name: string }[] };

export default function ProgressAssistantScreen() {
  const { user } = useAuth();
  const [nutrition, setNutrition] = useState<NutritionPlan | null>(null);
  const [routine, setRoutine] = useState<RoutinePlan | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user) return;
    (async () => {
      try {
        const snap = await getDoc(doc(db, "users", user.uid));
        if (snap.exists()) {
          const data = snap.data() as {
            nutritionPlan?: NutritionPlan;
            routinePlan?: RoutinePlan;
          };
          setNutrition(data.nutritionPlan ?? null);
          setRoutine(data.routinePlan ?? null);
        }
      } catch (e) {
        console.error(e);
      } finally {
        setLoading(false);
      }
    })();
  }, [user]);

  const askPerms = async () => {
    if (!("Notification" in window)) return alert("Sin soporte de notificaciones");
    const p = await Notification.requestPermission();
    if (p === "granted") alert("Notificaciones activadas");
  };
  const notify = (msg: string) => {
    if (Notification.permission === "granted") new Notification("TrainCoach", { body: msg });
  };

  useEffect(() => {
    if (!nutrition && !routine) return;
    const id = setInterval(() => {
      if (nutrition?.meals?.[0]) notify(`Comida: ${nutrition.meals[0].description}`);
      if (routine?.exercises?.[0]) notify(`Entrena: ${routine.exercises[0].name}`);
    }, 30000);
    return () => clearInterval(id);
  }, [nutrition, routine]);

  if (loading) return <p className="text-center p-6">Cargando...</p>;

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold text-center">Asistente de Progreso</h1>

      <div className="flex justify-center">
        <button
          onClick={askPerms}
          className="px-4 py-2 bg-indigo-600 text-white rounded-xl shadow hover:bg-indigo-700"
        >
          Activar recordatorios
        </button>
      </div>

      <div className="p-4 bg-white rounded-2xl shadow">
        <h2 className="font-semibold text-lg text-green-600">Nutrición</h2>
        {nutrition ? (
          <ul className="list-disc pl-5">
            {nutrition.meals.map((m, i) => (
              <li key={i}>
                <span className="font-semibold">{m.time}:</span> {m.description}
              </li>
            ))}
          </ul>
        ) : (
          <p>Sin plan de nutrición.</p>
        )}
      </div>

      <div className="p-4 bg-white rounded-2xl shadow">
        <h2 className="font-semibold text-lg text-blue-600">Rutinas</h2>
        {routine ? (
          <ul className="list-disc pl-5">
            {routine.exercises.map((e, i) => (
              <li key={i}>
                <span className="font-semibold">{e.time}:</span> {e.name}
              </li>
            ))}
          </ul>
        ) : (
          <p>Sin rutina.</p>
        )}
      </div>
    </div>
  );
}
