import { Box, Pagination, Grid, Typography } from "@mui/material"
import { useEffect, useState } from "react"

import CardItem from "./components/cardItem"
import Header from "presentation/components/header"
import Form from "./components/form"
import useSearchConstruction from "./hook/useSearchConstruction"


const Home = () => {
    const [currentPage, setCurrentPage] = useState(1);
    const itemsPerPage = 24;

    const { isLoading, constructions, refetch, total, isFetched } = useSearchConstruction()

    const handlePageChange = (event, newPage) => {
        setCurrentPage(newPage)
    }

    useEffect(() => {
        if (currentPage == 0) {
            let current = localStorage.getItem("page")
            if (current != undefined && current != null) {
                setCurrentPage(parseInt(current))
            }
            else {
                setCurrentPage(1)
            }
        }

    }, [currentPage]);

    return (
        <>
            <Header />
            <Box
                p={4}
                mb={10}
            >
                {
                    constructions.length > 0 &&
                    <Grid
                        style={{
                            marginTop: 15,
                            display: "flex",
                            justifyContent: "center"
                        }}
                    >
                        <Typography variant="h6">
                            {constructions.length} construction(s) trouvée(s)
                        </Typography>
                    </Grid>
                }
                <Grid style={{
                    display: "flex",
                    justifyContent: "center"
                }}
                    container spacing={2}
                >
                    {
                        isFetched && constructions.length == 0 &&
                        <Typography variant="h6">
                            Aucun resultat qui correspond à votre recherche
                        </Typography>
                    }
                    {
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
                        justifyContent: "center",
                        marginBottom: 15,
                    }}
                >
                    {
                        constructions.length > 0 &&
                        <Pagination
                            count={Math.ceil(total / itemsPerPage)}
                            page={currentPage}
                            onChange={handlePageChange}
                            sx={{ mt: 2 }}
                            color="success"
                        />
                    }
                </Box>
                <Form
                    currentPage={currentPage}
                    isLoading={isLoading}
                    handleSearch={refetch}
                />
            </Box>
        </>
    )
}
export default Home;
