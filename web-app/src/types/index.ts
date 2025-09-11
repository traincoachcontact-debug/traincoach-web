export type UserProfile = {
  displayName?: string;
  birthdate?: string;
  age?: number;
  sex?: "M" | "F" | "Otro" | string;
  heightcm ?: number;
  peso?: number;

  // Entrenamiento
  objetivo?: string;
  activityLevel?: string;
  diasSemana?: number;
  minutosSesion?: number;
  equipo?: string;
  lesiones?: string;

  // Salud/nutrición
  condiciones?: string;
  alergias?: string;
  preferencias?: string;
  dietaDiaria?: string;
  objetivosNutri?: string;
  actividad?: string;
  suenoHoras?: number;
  presupuesto?: string;
  cocinaQuien?: string;
  rutinaDiaria?: string;
};
