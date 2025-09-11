import { NavLink } from "react-router-dom";
import { Home, MessageSquare, UserCheck, Apple, Dumbbell } from "lucide-react";

export default function BottomNav() {
  return (
    <nav className="fixed bottom-0 left-0 w-full bg-gray-900 text-white flex justify-around py-2">
      <NavLink to="/" className="flex flex-col items-center" end>
        <Home size={20} /> Inicio
      </NavLink>
      <NavLink to="/messages" className="flex flex-col items-center">
        <MessageSquare size={20} /> Mensajes
      </NavLink>
      <NavLink to="/progress-assistant" className="flex flex-col items-center">
        <UserCheck size={20} /> Personal
      </NavLink>
      <NavLink to="/nutrition" className="flex flex-col items-center">
        <Apple size={20} /> Nutrición
      </NavLink>
      <NavLink to="/routine-assistant" className="flex flex-col items-center">
        <Dumbbell size={20} /> Rutinas
      </NavLink>
    </nav>
  );
}
