import api from "axios";
import apiUrl from "../../core/api";
import { toast } from "react-toastify";

const axios = api.create(
    { baseURL: apiUrl, withCredentials: false }
)

axios.interceptors.request.use((config) => {
    if(config.url!=="/api/auth/login"){
        config["headers"]["Authorization"] = `Bearer ${localStorage.getItem("token")}`
    }
    return config;
});

axios.interceptors.response.use(
    (response) => response,
    (error) => {
        console.log(error)
        if(error.response.status === 500) {
            toast.error("Erreur côté serveur") 
        }
        else {
            toast.error(JSON.stringify(error.response.data))
        }
        return {}
    }
)

export default axios
