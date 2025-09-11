export default function HomePage() {
  return (
    <div className="flex flex-col items-center justify-center text-center p-6">
      {/* Logo */}
      <img
        src="/traincoach-logo.jpg"
        alt="TrainCoach"
        className="w-40 h-40 mb-6 rounded-full shadow-lg"
      />

      {/* Nombre */}
      <h1 className="text-4xl font-bold text-green-600 mb-4">
        TrainCoach
      </h1>

      {/* Descripción */}
      <p className="text-lg text-white-700 max-w-xl">
        Tu entrenador personal y asesor nutricional inteligente.
        Con TrainCoach puedes crear rutinas personalizadas, recibir
        asesoría nutricional, chatear con otros usuarios y llevar un
        seguimiento de tu progreso, todo con la ayuda de inteligencia artificial.
      </p>

      {/* Botón de suscripción */}
      <a
        href="/membership"
        className="mt-8 bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg shadow-md transition-colors"
      >
        Suscríbete ahora
      </a>
      {/* Iniciar Sesion */}
      <a
        href="LoginPage"
        className="mt-8 bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg shadow-md transition-colors"
      >
        Iniciar Sesion
      </a>
    </div>
  );
}
