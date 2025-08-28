import { Box, Pagination, Button, Stack, Grid } from "@mui/material"
import { useEffect, useState } from "react"
import { Search } from "@mui/icons-material"
import useFindConstruction from "../../hooks/useFindConstruction"

import CardSkeleton from "presentation/components/skeleton"
import CardItem from "presentation/components/item"


const Construction = () => {

    const [currentPage, setCurrentPage] = useState(0);
    const itemsPerPage = 24;
    const [search, setSearch] = useState("")

    const { isLoading, montant, constructions, total, refetch } = useFindConstruction(currentPage, search)

    const handlePageChange = (event, newPage) => {
        setCurrentPage(newPage)
    }

    const handleSearch = (e) => {
        setSearch(e.target.value)
        let sessionSearch = localStorage.getItem("search")
        if (sessionSearch !== "") {
            localStorage.removeItem("search")
        }
    }

    useEffect(() => {
        let current = localStorage.getItem("page");
        let sessionSearch = localStorage.getItem("search");

        if (currentPage === 0) {
            setCurrentPage(current ? parseInt(current) : 1);
        }

        if (sessionSearch && sessionSearch !== "") {
            setSearch(sessionSearch);
        }

        refetch();
    }, [currentPage, search]);

    return (
        <>
            <Box p={4} mb={10}>
                <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", pb: 4 }}>
                    {
                        (search !== "" && constructions.length === 0) ?
                            <Box>Aucun resultat trouvé</Box> :
                            <Box>{constructions.length} construction(s), IFPB: {montant} Ar</Box>
                    }
                    <Stack
                        display="block"
                        direction="row"
                        bgcolor="#E1E1E1"
                        borderRadius={1}
                    >
                        <Search
                            sx={{
                                marginLeft: 1
                            }}
                        />
                        <input
                            value={search}
                            className="searching"
                            placeholder="Propriétaire ou adresse ou fkt"
                            onChange={handleSearch}
                            style={{
                                outline: "none",
                                border: "none",
                                backgroundColor: "transparent",
                                padding: "2px 18px 2px 5px"
                            }}
                        />
                        <Button
                            sx={{ textTransform: "none" }}
                            variant="contained"
                            size="medium"
                            onClick={() => {
                                setCurrentPage(1)
                                refetch()
                            }}
                            color="success" >
                            Rechercher
                        </Button>
                    </Stack>
                </Box>
                <Grid container spacing={2}>
                    {
                        isLoading ?
                            Array(24).fill(<CardSkeleton />).map((_, index) => <CardSkeleton key={index} />) :

                            constructions.map((item, index) => (
                                <Grid item key={index} xs={12} sm={12} md={4} lg={3}>
                                    <CardItem data={item} />
                                </Grid>
                            ))
                    }
                </Grid>
                <Box
                    sx={{
                        display: "flex",
                        justifyContent: "center"
                    }}
                >
                    {
                        constructions.length > 0 &&
                        <Pagination
                            count={Math.ceil(total / itemsPerPage)}
                            page={currentPage}
                            onChange={handlePageChange}
                            sx={{ mt: 2 }}
                            color="success"  // Définir la couleur des boutons de pagination en vert
                        />
                    }
                </Box>

            </Box>
        </>
    )
}
export default Construction;
