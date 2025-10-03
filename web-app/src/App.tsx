import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import MainLayout from "./components/layout/MainLayout";
import HomePage from "./pages/HomePage";
import MessagesPage from "./pages/MessagesPage";
import MembershipPage from "./pages/MembershipPage";
import ProgressAssistantScreen from "./pages/ProgressAssistantScreen";
import NutritionScreen from "./pages/NutritionScreen";
import RoutineAssistantScreen from "./pages/RoutineAssistantScreen";
import ProtectedRoute from "./components/layout/ProtectedRoute";
import ProfilePage from "./pages/ProfilePage";
import LoginPage from "./pages/LoginPage";

function App() {
  return (
    <Router>
      <MainLayout>
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route
            path="/messages"
            element={
              <ProtectedRoute minAge={18}>
                <MessagesPage />
              </ProtectedRoute>
            }
          />
          <Route path="/profile" element={<ProfilePage />} />
          <Route path="/progress-assistant" element={<ProgressAssistantScreen />} />
          <Route path="/nutrition" element={<NutritionScreen />} />
          <Route path="/routine-assistant" element={<RoutineAssistantScreen />} />
          <Route path="/membership" element={<MembershipPage />} />
          {/* 👇 cambio aquí */}
          <Route path="/login" element={<LoginPage />} />
        </Routes>
      </MainLayout>
    </Router>
  );
}

export default App;
