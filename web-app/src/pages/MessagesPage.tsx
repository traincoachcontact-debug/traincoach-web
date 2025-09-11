import { useAuth } from "../contexts/AuthContext";

export default function MessagesPage() {
  const { user } = useAuth();

  if (!user) return <p>No autenticado</p>;

  if (user.edad < 18) {
    return <p>Chat deshabilitado para menores de edad.</p>;
  }

  return (
    <div className="p-6">
      <h1 className="text-xl font-bold mb-4">Bandeja de Mensajes</h1>
      <p>Aquí iría el chat entre usuarios...</p>
    </div>
  );
}
