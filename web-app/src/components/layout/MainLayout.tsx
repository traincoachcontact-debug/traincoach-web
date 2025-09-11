import Sidebar from "./Sidebar";
import BottomNav from "./BottomNav";

export default function MainLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen bg-gray-100">
      {/* Barra lateral */}
      <div className="hidden md:block">
        <Sidebar />
      </div>

      {/* Contenido principal */}
      <main className="flex-1 bg-gray-900 text-white p-6">
        {children}
      </main>

      {/* Barra inferior para cell */}
      <div className="md:hidden">
        <BottomNav />
      </div>
    </div>
  );
}
