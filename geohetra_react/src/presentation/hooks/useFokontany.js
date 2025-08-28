import { useEffect, useState } from "react";
import axios from "data/api/axios";

function useFokontany() {
    const [fokontany, setFokontany] = useState([])

    const fetch = async () => {
        const response = await axios.get("/api/fokontany")
        setFokontany(response.data)
    }

    useEffect(() =>{
        fetch()
    }, [])

    return fokontany
}

export default useFokontany