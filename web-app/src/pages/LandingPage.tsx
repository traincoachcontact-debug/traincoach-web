import React from 'react';
import { Link } from 'react-router-dom';
import logo from '../assets/traincoach-logo.jpg';

const LandingPage: React.FC = () => {
  return (
    <div className="bg-gray-900 text-white min-h-screen flex flex-col">
      {/* Header */}
      <header className="p-4 flex justify-between items-center shadow-md">
        <div className="flex items-center">
          <img src={logo} alt="TrainCoach Logo" className="h-10 w-10 mr-3" />
          <h1 className="text-3xl font-bold tracking-tight">TrainCoach</h1>
        </div>
        <div>
          <Link to="/login" className="bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-2 px-4 rounded-lg transition duration-300">
            Iniciar Sesión
          </Link>
        </div>
      </header>

      {/* Hero Section */}
      <main className="flex-grow flex flex-col items-center justify-center text-center p-6">
        <h2 className="text-5xl font-extrabold mb-4 animate-fade-in-down">Eleva tu Entrenamiento al Siguiente Nivel</h2>
        <p className="text-lg text-gray-300 max-w-2xl mb-8 animate-fade-in-up">
          TrainCoach es tu compañero de fitness personal. Obtén planes de nutrición, rutinas de gimnasio personalizadas y seguimiento de progreso, todo impulsado por IA de vanguardia.
        </p>
        <Link to="/register" className="bg-green-500 hover:bg-green-600 text-white font-bold py-3 px-8 rounded-full text-lg transition duration-300 transform hover:scale-105">
          Únete Ahora
        </Link>
      </main>
    </div>
  );
};

export default LandingPage;