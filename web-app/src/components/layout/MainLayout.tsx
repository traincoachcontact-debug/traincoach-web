import Sidebar from "./Sidebar";
import BottomNav from "./BottomNav";
import React from "react";

interface MainLayoutProps {
  children: React.ReactNode;
}

export default function MainLayout({ children }: MainLayoutProps) {
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

      {/* Barra inferior para celular */}
      <div className="md:hidden">
        <BottomNav />
      </div>
    </div>
  );
}
