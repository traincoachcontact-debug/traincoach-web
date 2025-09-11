import { useEffect } from "react";
import { loadStripe } from "@stripe/stripe-js";

const stripePromise = loadStripe("pk_test_51OHB8...TU_PK_STRIPE"); // ⚠️ Reemplaza con tu clave pública de prueba

export default function MembershipPage() {
  useEffect(() => {
    const addPayPalScript = () => {
      const script = document.createElement("script");
      script.src = "https://www.paypal.com/sdk/js?client-id=sb&currency=USD"; // sb = sandbox
      script.async = true;
      document.body.appendChild(script);
    };
    addPayPalScript();
  }, []);

  const handleStripeCheckout = async () => {
    const stripe = await stripePromise;
    if (!stripe) return;

    // Aquí llamarías a tu backend para crear la sesión de pago
    const sessionId = "tu_session_id_de_prueba";
    stripe.redirectToCheckout({ sessionId });
  };

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Membresía TrainCoach</h1>
      <p className="mb-6">Accede a todas las funciones premium con tu suscripción.</p>

      <button
        onClick={handleStripeCheckout}
        className="bg-blue-600 text-white px-4 py-2 rounded"
      >
        Pagar con Stripe
      </button>

      <div id="paypal-button-container" className="mt-6"></div>
    </div>
  );
}
