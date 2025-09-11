import { Link } from "react-router-dom";
import { useAuth } from "../../contexts/AuthContext";

export default function Sidebar() {
  const { user } = useAuth();

  return (
    <aside className="bg-gray-800 text-white w-64 flex flex-col justify-between h-full p-4">
      <div>
        {user && (
          <div className="flex flex-col items-center mb-6">
            <img
              src={user.photoURL || "/default-profile.png"}
              alt="Perfil"
              className="w-20 h-20 rounded-full cursor-pointer"
              onClick={() => (window.location.href = "/profile")}
            />
            <p className="mt-2">{user.displayName || "Usuario"}</p>
          </div>
        )}

        <nav className="flex flex-col gap-4">
          <Link to="/" className="hover:text-green-400">Inicio</Link>
          <Link to="/messages" className="hover:text-green-400">Bandeja de mensajes</Link>
          <Link to="/progress-assistant" className="hover:text-green-400">Asesoría Personal</Link>
          <Link to="/nutrition" className="hover:text-green-400">Asesoría Nutricional</Link>
          <Link to="/routine-assistant" className="hover:text-green-400">Rutinas de Gimnasio</Link>

        </nav>
      </div>

      <button
        onClick={() => (window.location.href = "/settings")}
        className="bg-gray-700 hover:bg-gray-600 px-4 py-2 rounded mt-6"
      >
        Ajustes
      </button>
    </aside>
  );
}
