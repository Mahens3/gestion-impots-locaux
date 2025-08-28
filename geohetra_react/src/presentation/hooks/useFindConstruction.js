import ConstructionService from "domain/services/constructionService";
import { useEffect, useState } from "react";


function useFindConstruction(page, search) {
    const [montant, setMontant] = useState(0)
    const [constructions, setConstructions] = useState([])
    const [total, setTotal] = useState(0)
    const [isLoading, setIsLoading] = useState(false)

    const refetch = async () => {
        setIsLoading(true)
        let url = "";
        if (search != "") {
            url = `api/construction/search/page=${page}&value=${search}`
        }
        else {
            url = "api/construction/page/" + (page == 0 ? 1 : page)
        }
        
        await ConstructionService.search(url)
            .then((response) => {
                console.log(response)
                setIsLoading(false)
                setMontant(response.montant)
                setConstructions(response.construction)
                setTotal(response.total)
                localStorage.setItem("page", response.currentPage)
                localStorage.setItem("search", search)
            })

    }

    useEffect(() => {
        refetch()
    }, [])

    return { isLoading, montant, constructions, total, refetch }
}

export default useFindConstruction