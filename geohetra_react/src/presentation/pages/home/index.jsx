// ========== HOME PAGE ==========
import { 
  Box, 
  Pagination, 
  Grid, 
  Typography, 
  Container,
  Paper,
  alpha,
  useTheme,
  useMediaQuery
} from "@mui/material";
import { useEffect, useState } from "react";
import { Search as SearchIcon } from "@mui/icons-material";
import CardItem from "./components/cardItem";
import Header from "presentation/components/header";
import Form from "./components/form";
import useSearchConstruction from "./hook/useSearchConstruction";

const Home = () => {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 24;

  const { isLoading, constructions, refetch, total, isFetched } =
    useSearchConstruction();

  const handlePageChange = (event, newPage) => {
    setCurrentPage(newPage);
  };

  useEffect(() => {
    const savedPage = localStorage.getItem("page");
    if (savedPage) {
      setCurrentPage(parseInt(savedPage));
    }
  }, []);

  useEffect(() => {
    localStorage.setItem("page", currentPage);
  }, [currentPage]);

  return (
    <>
      <Header />
      <Box
        sx={{
          bgcolor: alpha('#f8fafc', 0.8),
          minHeight: 'calc(100vh - 64px)'
        }}
      >
        <Container maxWidth="xl">
          {/* Form de recherche */}
          <Box 
            sx={{ 
              display: 'flex', 
              justifyContent: 'center',
              pt: { xs: 4, sm: 5, md: 6 },
              pb: { xs: 3, sm: 4 }
            }}
          >
            <Form
              currentPage={currentPage}
              isLoading={isLoading}
              handleSearch={refetch}
            />
          </Box>

          {/* Résultats de recherche */}
          {isFetched && (
            <Box sx={{ pb: { xs: 4, sm: 6 } }}>
              {/* Compteur de résultats */}
              {constructions.length > 0 && (
                <Box 
                  sx={{ 
                    display: 'flex', 
                    justifyContent: 'center',
                    mb: { xs: 3, sm: 4 }
                  }}
                >
                  <Paper
                    elevation={0}
                    sx={{
                      px: 3,
                      py: 1.5,
                      borderRadius: 2,
                      border: `1px solid ${alpha('#000', 0.08)}`,
                      bgcolor: '#ffffff'
                    }}
                  >
                    <Typography
                      variant="h6"
                      sx={{
                        fontWeight: 600,
                        color: '#1e293b',
                        fontSize: { xs: '1rem', sm: '1.1rem' }
                      }}
                    >
                      {constructions.length} construction{constructions.length > 1 ? 's' : ''} trouvée{constructions.length > 1 ? 's' : ''}
                    </Typography>
                  </Paper>
                </Box>
              )}

              {/* Grid des résultats */}
              <Grid container spacing={{ xs: 2, sm: 2.5, md: 3 }}>
                {constructions.map((item, index) => (
                  <Grid item key={index} xs={12} sm={6} md={4} lg={3}>
                    <CardItem data={item} />
                  </Grid>
                ))}
              </Grid>

              {/* Empty State */}
              {constructions.length === 0 && (
                <Paper
                  elevation={0}
                  sx={{
                    p: { xs: 4, sm: 6 },
                    textAlign: 'center',
                    borderRadius: 2,
                    border: `1px solid ${alpha('#000', 0.08)}`,
                    bgcolor: '#ffffff'
                  }}
                >
                  <Box
                    sx={{
                      width: { xs: 60, sm: 80 },
                      height: { xs: 60, sm: 80 },
                      borderRadius: '50%',
                      bgcolor: alpha('#64748b', 0.1),
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      mx: 'auto',
                      mb: { xs: 2, sm: 3 }
                    }}
                  >
                    <SearchIcon 
                      sx={{ 
                        fontSize: { xs: '2rem', sm: '2.5rem' }, 
                        color: alpha('#64748b', 0.5) 
                      }} 
                    />
                  </Box>
                  <Typography
                    variant="h6"
                    sx={{
                      color: '#1e293b',
                      fontWeight: 600,
                      mb: 1,
                      fontSize: { xs: '1rem', sm: '1.1rem' }
                    }}
                  >
                    Aucun résultat trouvé
                  </Typography>
                  <Typography
                    variant="body2"
                    sx={{
                      color: alpha('#1e293b', 0.6),
                      fontSize: { xs: '0.85rem', sm: '0.9rem' }
                    }}
                  >
                    Aucune construction ne correspond à votre recherche
                  </Typography>
                </Paper>
              )}

              {/* Pagination */}
              {constructions.length > 0 && (
                <Box
                  sx={{
                    display: 'flex',
                    justifyContent: 'center',
                    mt: { xs: 4, sm: 5 }
                  }}
                >
                  <Paper
                    elevation={0}
                    sx={{
                      p: { xs: 1.5, sm: 2 },
                      borderRadius: 2,
                      border: `1px solid ${alpha('#000', 0.08)}`,
                      bgcolor: '#ffffff'
                    }}
                  >
                    <Pagination
                      count={Math.ceil(total / itemsPerPage)}
                      page={currentPage}
                      onChange={handlePageChange}
                      color="primary"
                      size={isMobile ? 'medium' : 'large'}
                      showFirstButton={!isMobile}
                      showLastButton={!isMobile}
                      sx={{
                        '& .MuiPaginationItem-root': {
                          fontWeight: 600,
                          fontSize: { xs: '0.85rem', sm: '0.9rem' },
                          '&.Mui-selected': {
                            bgcolor: '#1e40af',
                            color: '#ffffff',
                            '&:hover': {
                              bgcolor: '#1e3a8a'
                            }
                          }
                        }
                      }}
                    />
                  </Paper>
                </Box>
              )}
            </Box>
          )}
        </Container>
      </Box>
    </>
  );
};

export default Home;