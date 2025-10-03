// src/components/BottomNav.jsx
import { NavLink } from "react-router-dom"
import { Home, Dumbbell, Utensils, MessageCircle, User } from "lucide-react"

export default function BottomNav() {
  const links = [
    { to: "/", icon: <Home size={24} />, label: "Inicio" },
    { to: "/rutinas", icon: <Dumbbell size={24} />, label: "Rutinas" },
    { to: "/dietas", icon: <Utensils size={24} />, label: "Dietas" },
    { to: "/mensajes", icon: <MessageCircle size={24} />, label: "Mensajes" },
    { to: "/perfil", icon: <User size={24} />, label: "Perfil" },
  ]

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-white shadow-lg border-t border-gray-200">
      <ul className="flex justify-around items-center h-16">
        {links.map((link) => (
          <li key={link.to}>
            <NavLink
              to={link.to}
              className={({ isActive }) =>
                `flex flex-col items-center text-sm transition-colors ${
                  isActive ? "text-blue-600" : "text-gray-500 hover:text-gray-700"
                }`
              }
            >
              {link.icon}
              <span className="text-xs mt-1">{link.label}</span>
            </NavLink>
          </li>
        ))}
      </ul>
    </nav>
  )
}
