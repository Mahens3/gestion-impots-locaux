import axios from "data/api/axios";
import { postConstruction, postSearchConstruction } from "data/enpoint/construction";

class ConstructionService {
    static async post(body) {
        const response = await axios.post(postConstruction, body)
        return response.data
    }

    static async postSearch(body) {
        const response = await axios.post(postSearchConstruction, body)
        return response.data
    }

    static async put(url ,body) {
        const response = await axios.put(url, body)
        return response.data
    }

    static async search(url) {
        const response = await axios.get(url)
        return response.data
    }
}

export default ConstructionService