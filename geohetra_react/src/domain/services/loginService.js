import axios from "data/api/axios";
import { auth } from "data/enpoint/auth";


class LoginService {
    static async post(body) {
        const response = await axios.post(auth, body)
        return response.data
    }
}

export default LoginService