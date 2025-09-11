// web-app/src/pages/LoginPage.tsx

import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { signInWithEmailAndPassword, GoogleAuthProvider, signInWithPopup, getAdditionalUserInfo } from 'firebase/auth';
import { doc, setDoc, Timestamp} from 'firebase/firestore';
import { auth, db } from '../services/firebase.config';

const LoginPage: React.FC = () => {
  const navigate = useNavigate();

  // Estados para el formulario de email/contraseña
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  // Lógica para el inicio de sesión con Email y Contraseña
  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      await signInWithEmailAndPassword(auth, email, password);
      navigate('/home');
    } catch (err: any) {
      let errorMessage = 'Ocurrió un error al iniciar sesión. Por favor, inténtalo de nuevo.';
      if (err.code === 'auth/user-not-found' || err.code === 'auth/wrong-password' || err.code === 'auth/invalid-credential') {
        errorMessage = 'El correo electrónico o la contraseña son incorrectos.';
      }
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  // Lógica para el inicio de sesión con Google
  const handleGoogleLogin = async () => {
    setLoading(true);
    setError(null);
    const provider = new GoogleAuthProvider();

    try {
      const result = await signInWithPopup(auth, provider);
      const user = result.user;
      
      // Verificamos si es un usuario nuevo para crear su perfil en Firestore
      const additionalInfo = getAdditionalUserInfo(result);
      if (additionalInfo?.isNewUser) {
        const userDocRef = doc(db, 'users', user.uid);
        await setDoc(userDocRef, {
          uid: user.uid,
          displayName: user.displayName,
          email: user.email,
          photoURL: user.photoURL,
          dateOfBirth: null, // Importante: Google no proporciona la fecha de nacimiento.
          createdAt: Timestamp.now(),
          subscription: {
            status: 'free_user',
            role: 'free_user',
          }
        });
        // NOTA: Deberás pedirle al usuario que complete su fecha de nacimiento en su perfil
        // para que la lógica de restricción de edad funcione correctamente.
      }
      
      navigate('/home');

    } catch (err: any) {
      setError('No se pudo iniciar sesión con Google. Inténtalo de nuevo.');
      console.error("Error de inicio de sesión con Google:", err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-900 text-white p-4">
      <div className="p-8 rounded-lg shadow-2xl bg-gray-800 w-full max-w-md">
        <h1 className="text-3xl font-bold mb-6 text-center">Iniciar Sesión en TrainCoach</h1>
        
        {/* Formulario de Email/Contraseña */}
        <form onSubmit={handleLogin}>
          {/*... (código del formulario de email y contraseña que ya teníamos)... */}
          <div className="mb-4">
            <label htmlFor="email" className="block text-sm font-medium text-gray-400 mb-2">Correo Electrónico</label>
            <input type="email" id="email" value={email} onChange={(e) => setEmail(e.target.value)} className="w-full p-3 bg-gray-700 rounded-lg border border-gray-600 focus:outline-none focus:ring-2 focus:ring-indigo-500" required />
          </div>
          <div className="mb-6">
            <label htmlFor="password" className="block text-sm font-medium text-gray-400 mb-2">Contraseña</label>
            <input type="password" id="password" value={password} onChange={(e) => setPassword(e.target.value)} className="w-full p-3 bg-gray-700 rounded-lg border border-gray-600 focus:outline-none focus:ring-2 focus:ring-indigo-500" required />
          </div>
          <button type="submit" disabled={loading} className="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-3 rounded-lg transition duration-300 disabled:bg-gray-500">
            {loading? 'Iniciando...' : 'Iniciar Sesión'}
          </button>
        </form>

        {/* Separador */}
        <div className="my-6 flex items-center">
          <div className="flex-grow border-t border-gray-600"></div>
          <span className="flex-shrink mx-4 text-gray-400">O</span>
          <div className="flex-grow border-t border-gray-600"></div>
        </div>

        {/* Botón de Google */}
        <button onClick={handleGoogleLogin} disabled={loading} className="w-full flex items-center justify-center bg-white hover:bg-gray-200 text-black font-bold py-3 px-4 rounded-lg transition duration-300 disabled:bg-gray-400">
          <svg className="w-6 h-6 mr-3" viewBox="0 0 48 48">
            <path fill="#4285F4" d="M24 9.5c3.9 0 6.9 1.6 9.1 3.7l6.9-6.9C35.2 2.5 30.1 0 24 0 14.8 0 7.3 5.5 4.4 13.2l8.3 6.5C14.2 13.3 18.7 9.5 24 9.5z"></path>
            <path fill="#34A853" d="M46.5 24.8c0-1.6-.1-3.2-.4-4.8H24v9.1h12.7c-.5 3-2.1 5.6-4.6 7.3l7.6 5.9c4.4-4.1 7.2-10.1 7.2-17.5z"></path>
            <path fill="#FBBC05" d="M10.7 28.3c-.5-1.5-.8-3.1-.8-4.8s.3-3.3.8-4.8l-8.3-6.5C.9 15.8 0 19.8 0 24s.9 8.2 2.4 11.7l8.3-6.9z"></path>
            <path fill="#EA4335" d="M24 48c6.1 0 11.2-2 14.8-5.4l-7.6-5.9c-2 1.3-4.6 2.1-7.2 2.1-5.3 0-9.8-3.8-11.5-8.9l-8.3 6.5C7.3 42.5 14.8 48 24 48z"></path>
            <path fill="none" d="M0 0h48v48H0z"></path>
          </svg>
          Iniciar Sesión con Google
        </button>

        {error && <p className="text-red-500 text-sm mt-4 text-center">{error}</p>}

        <p className="text-center text-gray-400 mt-6">
          ¿No tienes una cuenta? <Link to="/register" className="text-indigo-400 hover:underline">Regístrate aquí</Link>
        </p>
      </div>
    </div>
  );
};

export default LoginPage;