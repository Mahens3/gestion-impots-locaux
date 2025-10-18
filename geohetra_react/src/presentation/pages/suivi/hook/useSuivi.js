import axios from "data/api/axios"
import { useCallback, useEffect, useState } from "react"

function useSuivi() {
    const [isLoading, setIsLoading] = useState(true)
    const [selectedFkt, setSelectedFkt] = useState(1)

    const [data, setData] = useState({
        "total": 0,
        "constructions": []
    })

    const fetch = useCallback(async () => {
        setIsLoading(true)
        await axios.get(`/api/construction/perfkt/${selectedFkt}`)
            .then((response) => {
                setData(response.data)
                setIsLoading(false)
            })
    },[selectedFkt])

    useEffect(() => {
        fetch()
    }, [fetch])

    return { isLoading, selectedFkt, setSelectedFkt, data }
}

export default useSuivi