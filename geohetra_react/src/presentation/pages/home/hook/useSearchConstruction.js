import ConstructionService from "domain/services/constructionService";
import { useState } from "react";

const initialData = {
    "isLoading": false,
    "isFetched": false,
    "constructions": [],
    "total": 0
}

function useSearchConstruction() {
    const [data, setData] = useState(initialData)

    const refetch = async (body) => {
        setData({ isLoading: true, ...initialData })
        await ConstructionService.postSearch(body)
            .then((response) => {
                setData({
                    isLoading: false,
                    isFetched: true,
                    ...response
                })
            })
    }

    return { refetch, ...data }
}

export default useSearchConstruction