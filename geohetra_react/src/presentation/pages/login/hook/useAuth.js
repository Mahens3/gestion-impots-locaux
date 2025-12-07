import LoginService from "domain/services/loginService";
import { useState } from "react";
import { useNavigate } from "react-router-dom";

function useAuth(data, helpers) {
  const navigate = useNavigate();
  const [isLoading, setIsLoading] = useState(false);

  const handleLogin = async () => {
    try {
      setIsLoading(true);

      const response = await LoginService.post(data);

      // Téléphone incorrect
      if (response.phone === false) {
        helpers.setErrors({ submit: "Numéro de téléphone incorrect" });
        return;
      }

      // Mot de passe incorrect
      if (response.mdp === false) {
        helpers.setErrors({ submit: "Mot de passe incorrect" });
        return;
      }

      // Succès
      localStorage.setItem("token", response.token);
      navigate("/admin/dashboard");
    } catch (error) {
      helpers.setErrors({ submit: "Erreur serveur" });
    } finally {
      setIsLoading(false);
    }
  };

  return { isLoading, handleLogin };
}

export default useAuth;
