import { useEffect, useState } from "react";
import { doc, getDoc, setDoc } from "firebase/firestore";
import { db } from "../services/firebase.config";
import { useAuth } from "../contexts/AuthContext";
import type { UserProfile } from "../types";

const init: UserProfile = {
  sex: "Otro",
  diasSemana: 3,
  minutosSesion: 45,
};

export default function ProfilePage() {
  const { user } = useAuth();
  const [form, setForm] = useState<UserProfile>(init);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (!user) return;
    (async () => {
      const ref = doc(db, "users", user.uid);
      const snap = await getDoc(ref);
      if (snap.exists()) setForm({ ...init, ...snap.data() } as UserProfile);
    })();
  }, [user]);

  const calcEdad = (birth?: string) => {
    if (!birth) return undefined;
    const b = new Date(birth);
    const t = new Date();
    let e = t.getFullYear() - b.getFullYear();
    const m = t.getMonth() - b.getMonth();
    if (m < 0 || (m === 0 && t.getDate() < b.getDate())) e--;
    return e;
  };

  const set = (k: keyof UserProfile, v: any) =>
    setForm((s) => ({ ...s, [k]: v, ...(k === "birthdate" ? { edad: calcEdad(v) } : {}) }));

  const save = async () => {
    if (!user) return;
    setSaving(true);
    const ref = doc(db, "users", user.uid);
    await setDoc(ref, { ...form, displayName: user.displayName ?? form.displayName }, { merge: true });
    setSaving(false);
    alert("Perfil guardado");
  };

  return (
    <div className="max-w-4xl mx-auto p-4 space-y-6">
      <h1 className="text-2xl font-bold">Perfil</h1>

      {/* Datos básicos */}
      <section className="grid md:grid-cols-3 gap-4">
        <label className="flex flex-col">Nombre
          <input className="input" value={form.displayName ?? ""} onChange={(e) => set("displayName", e.target.value)} />
        </label>
        <label className="flex flex-col">Fecha de nacimiento
          <input type="date" className="input" value={form.birthdate ?? ""} onChange={(e) => set("birthdate", e.target.value)} />
        </label>
        <label className="flex flex-col">Edad (auto)
          <input className="input" value={form.age ?? ""} readOnly />
        </label>
        <label className="flex flex-col">Sexo
          <select className="input" value={form.sex ?? ""} onChange={(e) => set("sex", e.target.value)}>
            <option>Otro</option><option>M</option><option>F</option>
          </select>
        </label>
        <label className="flex flex-col">Altura (cm)
          <input type="number" className="input" value={form.heightcm ?? ""} onChange={(e) => set("heightcm", Number(e.target.value))} />
        </label>
        <label className="flex flex-col">Peso (kg)
          <input type="number" className="input" value={form.peso ?? ""} onChange={(e) => set("peso", Number(e.target.value))} />
        </label>
      </section>

      {/* Entrenamiento */}
      <section>
        <h2 className="font-semibold mb-2">Entrenamiento</h2>
        <div className="grid md:grid-cols-3 gap-4">
          <label className="flex flex-col">Objetivo
            <input className="input" value={form.objetivo ?? ""} onChange={(e) => set("objetivo", e.target.value)} />
          </label>
          <label className="flex flex-col">Experiencia
            <select className="input" value={form.experience ?? ""} onChange={(e) => set("experience", e.target.value)}>
              <option>Principiante</option><option>Intermedio</option><option>Avanzado</option>
            </select>
          </label>
          <label className="flex flex-col">Días/semana
            <input type="number" className="input" value={form.diasSemana ?? 3} onChange={(e) => set("diasSemana", Number(e.target.value))} />
          </label>
          <label className="flex flex-col">Min/sesión
            <input type="number" className="input" value={form.minutosSesion ?? 45} onChange={(e) => set("minutosSesion", Number(e.target.value))} />
          </label>
          <label className="flex flex-col">Equipo
            <input className="input" value={form.equipo ?? ""} onChange={(e) => set("equipo", e.target.value)} placeholder="Gimnasio completo, mancuernas, peso corporal…" />
          </label>
          <label className="flex flex-col">Lesiones
            <input className="input" value={form.lesiones ?? ""} onChange={(e) => set("lesiones", e.target.value)} />
          </label>
        </div>
      </section>

      {/* Nutrición / estilo de vida */}
      <section>
        <h2 className="font-semibold mb-2">Nutrición y estilo de vida</h2>
        <div className="grid md:grid-cols-3 gap-4">
          <label className="flex flex-col">Objetivo nutricional
            <input className="input" value={form.objetivosNutri ?? ""} onChange={(e) => set("objetivosNutri", e.target.value)} />
          </label>
          <label className="flex flex-col">Alergias
            <input className="input" value={form.alergias ?? ""} onChange={(e) => set("alergias", e.target.value)} />
          </label>
          <label className="flex flex-col">Condiciones médicas
            <input className="input" value={form.condiciones ?? ""} onChange={(e) => set("condiciones", e.target.value)} />
          </label>
          <label className="flex flex-col">Preferencias/cultura
            <input className="input" value={form.preferencias ?? ""} onChange={(e) => set("preferencias", e.target.value)} />
          </label>
          <label className="flex flex-col">Actividad (sedentario, moderado…)
            <input className="input" value={form.actividad ?? ""} onChange={(e) => set("actividad", e.target.value)} />
          </label>
          <label className="flex flex-col">Sueño (h)
            <input type="number" className="input" value={form.suenoHoras ?? ""} onChange={(e) => set("suenoHoras", Number(e.target.value))} />
          </label>
          <label className="flex flex-col">Presupuesto
            <input className="input" value={form.presupuesto ?? ""} onChange={(e) => set("presupuesto", e.target.value)} />
          </label>
          <label className="flex flex-col">¿Quién cocina?
            <input className="input" value={form.cocinaQuien ?? ""} onChange={(e) => set("cocinaQuien", e.target.value)} />
          </label>
          <label className="flex flex-col md:col-span-3">Día típico de comida/bebida
            <textarea className="input h-24" value={form.dietaDiaria ?? ""} onChange={(e) => set("dietaDiaria", e.target.value)} />
          </label>
          <label className="flex flex-col md:col-span-3">Rutina/horarios
            <textarea className="input h-20" value={form.rutinaDiaria ?? ""} onChange={(e) => set("rutinaDiaria", e.target.value)} />
          </label>
        </div>
      </section>

      <button onClick={save} disabled={saving} className="bg-green-600 text-white px-4 py-2 rounded">
        {saving ? "Guardando…" : "Guardar"}
      </button>

      <style>{`.input{ @apply border rounded px-3 py-2 bg-white text-gray-900; }`}</style>
    </div>
  );
}
