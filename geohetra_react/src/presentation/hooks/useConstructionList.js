import { useEffect, useState } from "react"
import axios from "data/api/axios"

function useConstructionList() {
    const [data, setData] = useState([])
    const [selectedFokontany, setSelectedFokontany] = useState(1)

    const fetchConstruction = async () => {
        let response = await axios.get(`/api/construction/map/${selectedFokontany}`)
        setData(response.data.construction)
    }

    useEffect(() => {
        fetchConstruction()
    }, [selectedFokontany])

    return { data, selectedFokontany, setSelectedFokontany }
}

export default useConstructionList