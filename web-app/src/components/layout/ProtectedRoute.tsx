import { Navigate } from "react-router-dom";
import { useAuth } from "../../contexts/AuthContext";

export default function ProtectedRoute({ children, minAge = 18 }: any) {
  const { user, loading } = useAuth();

  if (loading) return <p>Cargando...</p>;
  if (!user) return <Navigate to="/login" />;

  const edad = user.edad || 0;
  if (edad < minAge) {
    return <p>Acceso restringido para menores de {minAge} años.</p>;
  }

  return children;
}
