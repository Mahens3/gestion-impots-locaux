import {
  Box,
  Pagination,
  Button,
  Grid,
  Container,
  Typography,
  Paper,
  InputBase,
  Chip,
  alpha,
  useTheme,
  useMediaQuery,
} from "@mui/material";
import { useEffect, useState } from "react";
import { Search, Home, AttachMoney, FilterList } from "@mui/icons-material";
import useFindConstruction from "../../hooks/useFindConstruction";
import CardSkeleton from "presentation/components/skeleton";
import CardItem from "presentation/components/item";
import { formatter } from "presentation/helpers/convertisseur";

const Construction = () => {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down("sm"));
  // const isTablet = useMediaQuery(theme.breakpoints.down('md'));

  const [currentPage, setCurrentPage] = useState(1);
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
    setCurrentPage(1);
  };

  const handleSearchClick = () => {
    setCurrentPage(1);
    refetch();
  };

  const handleKeyPress = (e) => {
    if (e.key === "Enter") {
      handleSearchClick();
    }
  };

  return (
    <Box
      sx={{
        bgcolor: alpha("#f8fafc", 0.8),
        minHeight: "calc(100vh - 70px)",
        py: { xs: 3, sm: 4 },
      }}
    >
      <Container maxWidth="xl">
        {/* Stats & Search Bar */}
        <Paper
          elevation={0}
          sx={{
            p: { xs: 2.5, sm: 3 },
            borderRadius: 2,
            border: `1px solid ${alpha("#000", 0.08)}`,
            bgcolor: "#ffffff",
            mb: { xs: 3, sm: 4 },
          }}
        >
          {/* Stats Row */}
          <Box
            sx={{
              display: "flex",
              flexDirection: { xs: "column", sm: "row" },
              gap: { xs: 2, sm: 3 },
            }}
          >
            {/* Nombre de constructions */}
            <Box
              sx={{
                display: "flex",
                alignItems: "center",
                gap: 1.5,
                flex: { sm: 1 },
              }}
            >
              <Box
                sx={{
                  p: 1.25,
                  borderRadius: 1.5,
                  bgcolor: alpha("#10b981", 0.1),
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                }}
              >
                <Home sx={{ color: "#059669", fontSize: "1.5rem" }} />
              </Box>
              <Box>
                <Typography
                  variant="caption"
                  sx={{
                    color: alpha("#1e293b", 0.6),
                    fontSize: "0.75rem",
                    fontWeight: 500,
                    display: "block",
                  }}
                >
                  {search !== "" && constructions.length === 0
                    ? "Aucun résultat trouvé"
                    : "Constructions"}
                </Typography>
                <Typography
                  variant="h6"
                  sx={{
                    color: "#1e293b",
                    fontWeight: 700,
                    fontSize: { xs: "1.15rem", sm: "1.3rem" },
                    lineHeight: 1.2,
                  }}
                >
                  {formatter(constructions.length)}
                </Typography>
              </Box>
            </Box>

            {/* IFPB Total */}
            <Box
              sx={{
                display: "flex",
                alignItems: "center",
                gap: 1.5,
                flex: { sm: 1 },
              }}
            >
              <Box
                sx={{
                  p: 1.25,
                  borderRadius: 1.5,
                  bgcolor: alpha("#3b82f6", 0.1),
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                }}
              >
                <AttachMoney sx={{ color: "#2563eb", fontSize: "1.5rem" }} />
              </Box>
              <Box>
                <Typography
                  variant="caption"
                  sx={{
                    color: alpha("#1e293b", 0.6),
                    fontSize: "0.75rem",
                    fontWeight: 500,
                    display: "block",
                  }}
                >
                  IFPB Total
                </Typography>
                <Typography
                  variant="h6"
                  sx={{
                    color: "#1e293b",
                    fontWeight: 700,
                    fontSize: { xs: "1.15rem", sm: "1.3rem" },
                    lineHeight: 1.2,
                    whiteSpace: "nowrap",
                    overflow: "hidden",
                    textOverflow: "ellipsis",
                  }}
                >
                  {formatter(montant)} Ar
                </Typography>
              </Box>
            </Box>
            {/* Search Bar */}
            <Box
              sx={{
                display: "flex",
                flexDirection: { xs: "column", sm: "row" },
                gap: { xs: 1.5, sm: 2 },
              }}
            >
              <Paper
                elevation={0}
                sx={{
                  display: "flex",
                  alignItems: "center",
                  flex: 1,
                  bgcolor: alpha("#000", 0.02),
                  border: `1px solid ${alpha("#000", 0.08)}`,
                  borderRadius: 1.5,
                  px: 2,
                  py: 1,
                  transition: "all 0.2s ease",
                  "&:focus-within": {
                    bgcolor: "#ffffff",
                    border: `1px solid ${alpha("#1e40af", 0.3)}`,
                    boxShadow: `0 0 0 3px ${alpha("#1e40af", 0.1)}`,
                  },
                }}
              >
                <Search
                  sx={{
                    color: alpha("#1e293b", 0.4),
                    mr: 1.5,
                    fontSize: "1.25rem",
                  }}
                />
                <InputBase
                  value={search}
                  placeholder={
                    isMobile
                      ? "Rechercher..."
                      : "Propriétaire, adresse ou fokontany..."
                  }
                  onChange={handleSearch}
                  onKeyPress={handleKeyPress}
                  sx={{
                    flex: 1,
                    fontSize: { xs: "0.9rem", sm: "0.95rem" },
                    color: "#1e293b",
                    "& input::placeholder": {
                      color: alpha("#1e293b", 0.4),
                      opacity: 1,
                    },
                  }}
                />
                {search && (
                  <Chip
                    label="Effacer"
                    size="small"
                    onClick={() => setSearch("")}
                    sx={{
                      height: "24px",
                      fontSize: "0.75rem",
                      bgcolor: alpha("#1e40af", 0.1),
                      color: "#1e40af",
                      fontWeight: 600,
                      "&:hover": {
                        bgcolor: alpha("#1e40af", 0.2),
                      },
                    }}
                  />
                )}
              </Paper>

              <Button
                variant="contained"
                startIcon={<Search />}
                onClick={handleSearchClick}
                sx={{
                  bgcolor: "#1e40af",
                  color: "#ffffff",
                  fontWeight: 600,
                  textTransform: "none",
                  px: { xs: 3, sm: 4 },
                  py: 1.25,
                  borderRadius: 1.5,
                  fontSize: { xs: "0.9rem", sm: "0.95rem" },
                  whiteSpace: "nowrap",
                  boxShadow: `0 4px 12px ${alpha("#1e40af", 0.3)}`,
                  "&:hover": {
                    bgcolor: "#1e3a8a",
                    boxShadow: `0 6px 16px ${alpha("#1e40af", 0.4)}`,
                    transform: "translateY(-2px)",
                  },
                  transition: "all 0.3s ease",
                }}
              >
                {isMobile ? "Rechercher" : "Rechercher"}
              </Button>
            </Box>
          </Box>

          {/* Active filters */}
          {search && (
            <Box mt={2} display="flex" alignItems="center" gap={1}>
              <FilterList
                sx={{ fontSize: "1rem", color: alpha("#1e293b", 0.5) }}
              />
              <Typography
                variant="caption"
                sx={{ color: alpha("#1e293b", 0.6), fontSize: "0.75rem" }}
              >
                Filtre actif:
              </Typography>
              <Chip
                label={`"${search}"`}
                size="small"
                onDelete={() => setSearch("")}
                sx={{
                  bgcolor: alpha("#1e40af", 0.1),
                  color: "#1e40af",
                  fontWeight: 600,
                  fontSize: "0.75rem",
                }}
              />
            </Box>
          )}
        </Paper>

        {/* Grid des constructions */}
        <Grid container spacing={{ xs: 2, sm: 2.5, md: 3 }}>
          {isLoading
            ? Array.from({ length: 24 }).map((_, index) => (
                <CardSkeleton key={index} />
              ))
            : constructions.map((item, index) => (
                <Grid item key={index} xs={12} sm={6} md={4} lg={3}>
                  <CardItem data={item} />
                </Grid>
              ))}
        </Grid>

        {/* Empty State */}
        {!isLoading && constructions.length === 0 && (
          <Paper
            elevation={0}
            sx={{
              p: 6,
              textAlign: "center",
              borderRadius: 2,
              border: `1px solid ${alpha("#000", 0.08)}`,
              bgcolor: "#ffffff",
              mt: 4,
            }}
          >
            <Box
              sx={{
                width: 80,
                height: 80,
                borderRadius: "50%",
                bgcolor: alpha("#64748b", 0.1),
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                mx: "auto",
                mb: 3,
              }}
            >
              <Search
                sx={{ fontSize: "2.5rem", color: alpha("#64748b", 0.5) }}
              />
            </Box>
            <Typography
              variant="h6"
              sx={{
                color: "#1e293b",
                fontWeight: 600,
                mb: 1,
                fontSize: { xs: "1rem", sm: "1.1rem" },
              }}
            >
              Aucun résultat trouvé
            </Typography>
            <Typography
              variant="body2"
              sx={{
                color: alpha("#1e293b", 0.6),
                mb: 3,
                fontSize: { xs: "0.85rem", sm: "0.9rem" },
              }}
            >
              Essayez de modifier vos critères de recherche
            </Typography>
            <Button
              variant="outlined"
              onClick={() => setSearch("")}
              sx={{
                borderColor: alpha("#1e40af", 0.3),
                color: "#1e40af",
                textTransform: "none",
                fontWeight: 600,
                "&:hover": {
                  borderColor: "#1e40af",
                  bgcolor: alpha("#1e40af", 0.05),
                },
              }}
            >
              Réinitialiser la recherche
            </Button>
          </Paper>
        )}

        {/* Pagination */}
        {constructions.length > 0 && (
          <Box
            sx={{
              display: "flex",
              justifyContent: "center",
              mt: { xs: 4, sm: 5 },
            }}
          >
            <Paper
              elevation={0}
              sx={{
                p: { xs: 1.5, sm: 2 },
                borderRadius: 2,
                border: `1px solid ${alpha("#000", 0.08)}`,
                bgcolor: "#ffffff",
                display: "flex",
                justifyContent: "center", // 👈 centre horizontalement
                alignItems: "center", // 👈 centre verticalement (optionnel)
              }}
            >
              <Pagination
                count={Math.ceil(total / itemsPerPage)}
                page={currentPage}
                onChange={handlePageChange}
                color="primary"
                size={isMobile ? "medium" : "large"}
                showFirstButton={!isMobile}
                showLastButton={!isMobile}
                sx={{
                  "& .MuiPaginationItem-root": {
                    fontWeight: 600,
                    fontSize: { xs: "0.85rem", sm: "0.9rem" },
                    "&.Mui-selected": {
                      bgcolor: "#1e40af",
                      color: "#ffffff",
                      "&:hover": {
                        bgcolor: "#1e3a8a",
                      },
                    },
                  },
                }}
              />
            </Paper>
          </Box>
        )}
      </Container>
    </Box>
  );
};

export default Construction;
