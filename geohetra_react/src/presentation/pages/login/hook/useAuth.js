import LoginService from "domain/services/loginService";
import { useState } from "react";
import { useNavigate } from "react-router-dom";


function useAuth(data, helpers) {
    const navigate = useNavigate()
    const [isLoading, setIsLoading] = useState(false)

    const handleLogin = async () => {
        setIsLoading(true)
        await LoginService.post(data)
            .then((response) => {
                if (response.email === false) {
                    helpers.setErrors({ submit: "Utilisateur inéxistant" });
                }
                else {
                    if (response.password === false) {
                        helpers.setErrors({ submit: "Mot de passe incorrect" });
                    }
                    else {
                        localStorage.setItem("token", response)
                        navigate("/admin/dashboard")
                    }
                }
                setIsLoading(false)
            })

    }

    return { isLoading, handleLogin }
}

export default useAuth