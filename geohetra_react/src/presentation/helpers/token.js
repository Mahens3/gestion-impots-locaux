import { jwtDecode } from "jwt-decode"

function getToken() {
    const storage = localStorage.getItem("token")
    try {
        const decoded = jwtDecode(storage)
        return decoded
    }
    catch (e) {
        return null
    }

}

export default getToken