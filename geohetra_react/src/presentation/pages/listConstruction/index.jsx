import { Box, Pagination, Button, Stack, Grid } from "@mui/material";
import { useEffect, useState } from "react";
import { Search } from "@mui/icons-material";
import useFindConstruction from "../../hooks/useFindConstruction";
import CardSkeleton from "presentation/components/skeleton";
import CardItem from "presentation/components/item";

const Construction = () => {
  const [currentPage, setCurrentPage] = useState(1);  // Pagination MUI commence à 1
  const [search, setSearch] = useState("");

  const itemsPerPage = 24;

  const { isLoading, montant, constructions, total, refetch } =
    useFindConstruction(currentPage, search);

  // Charger les valeurs enregistrées une seule fois
  useEffect(() => {
    const savedPage = localStorage.getItem("page");
    const savedSearch = localStorage.getItem("search");

    if (savedPage) setCurrentPage(parseInt(savedPage));
    if (savedSearch) setSearch(savedSearch);
  }, []);

  // Sauvegarde automatique + refetch
  useEffect(() => {
    localStorage.setItem("page", currentPage);
    localStorage.setItem("search", search);
    refetch();
  }, [currentPage, search, refetch]);

  const handlePageChange = (_, newPage) => {
    setCurrentPage(newPage);
  };

  const handleSearch = (e) => {
    setSearch(e.target.value);
    setCurrentPage(1); // Revenir à la première page lors d’une recherche
  };

  return (
    <Box p={4} mb={10}>
      <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", pb: 4 }}>
        
        {search !== "" && constructions.length === 0 ? (
          <Box>Aucun résultat trouvé</Box>
        ) : (
          <Box>{constructions.length} construction(s), IFPB: {montant} Ar</Box>
        )}

        <Stack direction="row" bgcolor="#E1E1E1" borderRadius={1}>
          <Search sx={{ marginLeft: 1 }} />
          <input
            value={search}
            placeholder="Propriétaire ou adresse ou fkt"
            onChange={handleSearch}
            style={{
              outline: "none",
              border: "none",
              backgroundColor: "transparent",
              padding: "2px 18px 2px 5px",
            }}
          />
          <Button
            sx={{ textTransform: "none", backgroundColor: "#1976d2" }}
            variant="contained"
            onClick={() => refetch()}
          >
            Rechercher
          </Button>
        </Stack>
      </Box>

      <Grid container spacing={2}>
        {isLoading
          ? Array.from({ length: 24 }).map((_, index) => <CardSkeleton key={index} />)
          : constructions.map((item, index) => (
              <Grid item key={index} xs={12} sm={12} md={4} lg={3}>
                <CardItem data={item} />
              </Grid>
            ))}
      </Grid>

      <Box sx={{ display: "flex", justifyContent: "center" }}>
        {constructions.length > 0 && (
          <Pagination
            count={Math.ceil(total / itemsPerPage)}
            page={currentPage}
            onChange={handlePageChange}
            sx={{ mt: 2 }}
            color="success"
          />
        )}
      </Box>
    </Box>
  );
};

export default Construction;
