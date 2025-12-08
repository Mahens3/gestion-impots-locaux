import { useMemo } from "react";
import {
  Box,
  Container,
  Paper,
  Typography,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  alpha,
  // useTheme,
  // useMediaQuery
} from "@mui/material";
import { Print, AttachMoney, Home } from "@mui/icons-material";
import useSuivi from "./hook/useSuivi";
import useFokontany from "presentation/hooks/useFokontany";
import { Spinner } from "presentation/components/loader";
import { formatter } from "presentation/helpers/convertisseur";

const Suivi = () => {
  // const theme = useTheme();
  // const isMobile = useMediaQuery(theme.breakpoints.down('sm'));

  const { isLoading, selectedFkt, setSelectedFkt, data } = useSuivi();
  const fokontany = useFokontany();

  const print = () => {
    window.print();
  };

  const nomfokontany = useMemo(() => {
    const value = fokontany.filter((value) => value.id === selectedFkt);
    return value[0] !== undefined ? value[0].nomfokontany : "";
  }, [fokontany, selectedFkt]);

  return (
    <Box
      sx={{
        bgcolor: alpha('#f8fafc', 0.8),
        minHeight: 'calc(100vh - 70px)',
        py: { xs: 3, sm: 4 },
        '@media print': {
          bgcolor: '#ffffff',
          py: 2
        }
      }}
    >
      <Container maxWidth="xl">
        {/* Print Header - Visible only on print */}
        <Box
          className="print-only"
          sx={{
            display: 'none',
            '@media print': {
              display: 'block',
              mb: 3,
              pb: 2,
              borderBottom: '2px solid #1e293b'
            }
          }}
        >
          <Typography
            variant="h5"
            sx={{
              fontWeight: 700,
              color: '#1e293b',
              mb: 1
            }}
          >
            Suivi des paiements IFPB
          </Typography>
          <Box display="flex" justifyContent="space-between" alignItems="center">
            <Typography variant="h6" sx={{ fontWeight: 600, color: '#1e293b' }}>
              Fokontany: {fokontany.length > 0 && nomfokontany}
            </Typography>
            <Typography variant="h6" sx={{ fontWeight: 700, color: '#2563eb' }}>
              Total: {formatter(data.total)} Ar
            </Typography>
          </Box>
        </Box>

        {/* Controls & Stats Section - Hidden on print */}
        <Paper
          elevation={0}
          className="no-print"
          sx={{
            p: { xs: 2.5, sm: 3 },
            borderRadius: 2,
            border: `1px solid ${alpha('#000', 0.08)}`,
            bgcolor: '#ffffff',
            mb: { xs: 3, sm: 4 }
          }}
        >
          {/* Row: Select + Stats + Print Button */}
          <Box
            sx={{
              display: 'flex',
              flexDirection: { xs: 'column', md: 'row' },
              gap: { xs: 2, sm: 2.5 },
              alignItems: { xs: 'stretch', md: 'center' }
            }}
          >
            {/* Select Fokontany */}
            <FormControl 
              sx={{ 
                width: { xs: '100%', md: 280 },
                flexShrink: 0,
                '& .MuiOutlinedInput-root': {
                  borderRadius: 1.5,
                  '&:hover .MuiOutlinedInput-notchedOutline': {
                    borderColor: alpha('#1e40af', 0.3)
                  },
                  '&.Mui-focused .MuiOutlinedInput-notchedOutline': {
                    borderColor: '#1e40af',
                    borderWidth: '2px'
                  }
                }
              }}
            >
              <InputLabel 
                sx={{ 
                  fontWeight: 500,
                  fontSize: { xs: '0.9rem', sm: '0.95rem' },
                  '&.Mui-focused': {
                    color: '#1e40af'
                  }
                }}
              >
                Fokontany
              </InputLabel>
              <Select
                value={selectedFkt}
                label="Fokontany"
                onChange={(e) => setSelectedFkt(e.target.value)}
                sx={{
                  fontSize: { xs: '0.9rem', sm: '0.95rem' }
                }}
              >
                {fokontany.map((item, key) => (
                  <MenuItem 
                    key={key} 
                    value={item.id}
                    sx={{
                      fontSize: { xs: '0.9rem', sm: '0.95rem' },
                      '&:hover': {
                        bgcolor: alpha('#1e40af', 0.08)
                      }
                    }}
                  >
                    {item.nomfokontany}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>

            {/* Stats inline - Visible only if data exists */}
            {fokontany.length > 0 && !isLoading && (
              <Box
                sx={{
                  display: 'flex',
                  flexDirection: { xs: 'column', sm: 'row' },
                  gap: { xs: 1.5, sm: 2 },
                  flex: 1
                }}
              >
                {/* Nombre de constructions */}
                <Box
                  sx={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: 1.5,
                    p: { xs: 1.5, sm: 2 },
                    borderRadius: 1.5,
                    bgcolor: alpha('#f59e0b', 0.05),
                    border: `1px solid ${alpha('#f59e0b', 0.1)}`,
                    flex: 1,
                    transition: 'all 0.2s ease',
                    '&:hover': {
                      bgcolor: alpha('#f59e0b', 0.08),
                      transform: 'translateY(-2px)'
                    }
                  }}
                >
                  <Box
                    sx={{
                      p: 1,
                      borderRadius: 1.25,
                      bgcolor: alpha('#f59e0b', 0.15),
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      flexShrink: 0
                    }}
                  >
                    <Home sx={{ color: '#d97706', fontSize: { xs: '1.25rem', sm: '1.4rem' } }} />
                  </Box>
                  <Box flex={1} minWidth={0}>
                    <Typography
                      variant="caption"
                      sx={{
                        color: alpha('#1e293b', 0.6),
                        fontSize: { xs: '0.7rem', sm: '0.75rem' },
                        fontWeight: 500,
                        display: 'block',
                        mb: 0.25
                      }}
                    >
                      Constructions
                    </Typography>
                    <Typography
                      variant="body2"
                      sx={{
                        color: '#1e293b',
                        fontWeight: 700,
                        fontSize: { xs: '0.9rem', sm: '1rem' },
                        lineHeight: 1.2,
                        whiteSpace: 'nowrap',
                        overflow: 'hidden',
                        textOverflow: 'ellipsis'
                      }}
                    >
                      {formatter(data.constructions?.length || 0)}
                    </Typography>
                  </Box>
                </Box>

                {/* Total IFPB */}
                <Box
                  sx={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: 1.5,
                    p: { xs: 1.5, sm: 2 },
                    borderRadius: 1.5,
                    bgcolor: alpha('#3b82f6', 0.05),
                    border: `1px solid ${alpha('#3b82f6', 0.1)}`,
                    flex: 1,
                    transition: 'all 0.2s ease',
                    '&:hover': {
                      bgcolor: alpha('#3b82f6', 0.08),
                      transform: 'translateY(-2px)'
                    }
                  }}
                >
                  <Box
                    sx={{
                      p: 1,
                      borderRadius: 1.25,
                      bgcolor: alpha('#3b82f6', 0.15),
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      flexShrink: 0
                    }}
                  >
                    <AttachMoney sx={{ color: '#2563eb', fontSize: { xs: '1.25rem', sm: '1.4rem' } }} />
                  </Box>
                  <Box flex={1} minWidth={0}>
                    <Typography
                      variant="caption"
                      sx={{
                        color: alpha('#1e293b', 0.6),
                        fontSize: { xs: '0.7rem', sm: '0.75rem' },
                        fontWeight: 500,
                        display: 'block',
                        mb: 0.25
                      }}
                    >
                      Total IFPB
                    </Typography>
                    <Typography
                      variant="body2"
                      sx={{
                        color: '#1e293b',
                        fontWeight: 700,
                        fontSize: { xs: '0.9rem', sm: '1rem' },
                        lineHeight: 1.2,
                        whiteSpace: 'nowrap',
                        overflow: 'hidden',
                        textOverflow: 'ellipsis'
                      }}
                    >
                      {formatter(data.total)} Ar
                    </Typography>
                  </Box>
                </Box>
              </Box>
            )}

            {/* Print Button */}
            <Button
              variant="contained"
              startIcon={<Print />}
              onClick={print}
              sx={{
                bgcolor: '#1e40af',
                color: '#ffffff',
                fontWeight: 600,
                textTransform: 'none',
                px: { xs: 3, sm: 4 },
                py: { xs: 1.25, sm: 1.5 },
                borderRadius: 1.5,
                fontSize: { xs: '0.9rem', sm: '0.95rem' },
                whiteSpace: 'nowrap',
                flexShrink: 0,
                boxShadow: `0 4px 12px ${alpha('#1e40af', 0.3)}`,
                '&:hover': {
                  bgcolor: '#1e3a8a',
                  boxShadow: `0 6px 16px ${alpha('#1e40af', 0.4)}`,
                  transform: 'translateY(-2px)'
                },
                transition: 'all 0.3s ease'
              }}
            >
              Imprimer
            </Button>
          </Box>
        </Paper>

        {/* Table Section */}
        {fokontany.length === 0 || isLoading ? (
          <Box display="flex" justifyContent="center" alignItems="center" minHeight="40vh">
            <Spinner />
          </Box>
        ) : (
          <TableContainer
            component={Paper}
            elevation={0}
            sx={{
              borderRadius: 2,
              border: `1px solid ${alpha('#000', 0.08)}`,
              '@media print': {
                border: '1px solid #000',
                boxShadow: 'none'
              }
            }}
          >
            <Table
              sx={{
                minWidth: 650,
                '@media print': {
                  '& td, & th': {
                    fontSize: '10pt',
                    padding: '8px'
                  }
                }
              }}
            >
              <TableHead>
                <TableRow
                  sx={{
                    bgcolor: alpha('#1e40af', 0.05),
                    '@media print': {
                      bgcolor: '#e5e7eb !important'
                    }
                  }}
                >
                  <TableCell
                    sx={{
                      fontWeight: 700,
                      color: '#1e293b',
                      fontSize: { xs: '0.8rem', sm: '0.85rem', md: '0.9rem' },
                      borderBottom: `2px solid ${alpha('#1e40af', 0.2)}`
                    }}
                  >
                    Article
                  </TableCell>
                  <TableCell
                    sx={{
                      fontWeight: 700,
                      color: '#1e293b',
                      fontSize: { xs: '0.8rem', sm: '0.85rem', md: '0.9rem' },
                      borderBottom: `2px solid ${alpha('#1e40af', 0.2)}`
                    }}
                  >
                    Propriétaire
                  </TableCell>
                  <TableCell
                    sx={{
                      fontWeight: 700,
                      color: '#1e293b',
                      fontSize: { xs: '0.8rem', sm: '0.85rem', md: '0.9rem' },
                      borderBottom: `2px solid ${alpha('#1e40af', 0.2)}`
                    }}
                  >
                    Adresse
                  </TableCell>
                  <TableCell
                    sx={{
                      fontWeight: 700,
                      color: '#1e293b',
                      fontSize: { xs: '0.8rem', sm: '0.85rem', md: '0.9rem' },
                      borderBottom: `2px solid ${alpha('#1e40af', 0.2)}`
                    }}
                  >
                    Boriboritany
                  </TableCell>
                  <TableCell
                    align="right"
                    sx={{
                      fontWeight: 700,
                      color: '#1e293b',
                      fontSize: { xs: '0.8rem', sm: '0.85rem', md: '0.9rem' },
                      borderBottom: `2px solid ${alpha('#1e40af', 0.2)}`
                    }}
                  >
                    IFPB
                  </TableCell>
                  <TableCell
                    align="right"
                    sx={{
                      fontWeight: 700,
                      color: '#1e293b',
                      fontSize: { xs: '0.8rem', sm: '0.85rem', md: '0.9rem' },
                      borderBottom: `2px solid ${alpha('#1e40af', 0.2)}`
                    }}
                  >
                    Paiement
                  </TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {data.constructions?.map((construction, key) => (
                  <TableRow
                    key={key}
                    sx={{
                      '&:hover': {
                        bgcolor: alpha('#1e40af', 0.03)
                      },
                      '&:nth-of-type(odd)': {
                        bgcolor: alpha('#000', 0.02)
                      },
                      '@media print': {
                        '&:hover': {
                          bgcolor: 'transparent'
                        },
                        pageBreakInside: 'avoid'
                      }
                    }}
                  >
                    <TableCell
                      sx={{
                        fontSize: { xs: '0.75rem', sm: '0.8rem', md: '0.85rem' },
                        color: '#1e293b'
                      }}
                    >
                      {construction.article}
                    </TableCell>
                    <TableCell
                      sx={{
                        fontSize: { xs: '0.75rem', sm: '0.8rem', md: '0.85rem' },
                        color: '#1e293b',
                        fontWeight: 500
                      }}
                    >
                      {construction.proprietaire}
                    </TableCell>
                    <TableCell
                      sx={{
                        fontSize: { xs: '0.75rem', sm: '0.8rem', md: '0.85rem' },
                        color: alpha('#1e293b', 0.8)
                      }}
                    >
                      {construction.adresse}
                    </TableCell>
                    <TableCell
                      sx={{
                        fontSize: { xs: '0.75rem', sm: '0.8rem', md: '0.85rem' },
                        color: alpha('#1e293b', 0.8)
                      }}
                    >
                      {construction.boriboritany}
                    </TableCell>
                    <TableCell
                      align="right"
                      sx={{
                        fontSize: { xs: '0.75rem', sm: '0.8rem', md: '0.85rem' },
                        color: '#1e293b',
                        fontWeight: 600,
                        whiteSpace: 'nowrap'
                      }}
                    >
                      {construction.ifpb}
                    </TableCell>
                    <TableCell
                      align="right"
                      sx={{
                        fontSize: { xs: '0.75rem', sm: '0.8rem', md: '0.85rem' },
                        color: '#059669',
                        fontWeight: 600,
                        whiteSpace: 'nowrap'
                      }}
                    >
                      {construction.payment}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        )}

        {/* Empty State */}
        {!isLoading && data.constructions?.length === 0 && (
          <Paper
            elevation={0}
            className="no-print"
            sx={{
              p: { xs: 4, sm: 6 },
              textAlign: 'center',
              borderRadius: 2,
              border: `1px solid ${alpha('#000', 0.08)}`,
              bgcolor: '#ffffff',
              mt: 4
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
              <Home sx={{ fontSize: { xs: '2rem', sm: '2.5rem' }, color: alpha('#64748b', 0.5) }} />
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
              Aucune construction trouvée
            </Typography>
            <Typography
              variant="body2"
              sx={{
                color: alpha('#1e293b', 0.6),
                fontSize: { xs: '0.85rem', sm: '0.9rem' }
              }}
            >
              Sélectionnez un fokontany pour voir les constructions
            </Typography>
          </Paper>
        )}
      </Container>

      {/* Print Styles */}
      <style>
        {`
          @media print {
            .no-print {
              display: none !important;
            }
            body {
              background: white !important;
            }
            @page {
              margin: 1cm;
            }
          }
        `}
      </style>
    </Box>
  );
};

export default Suivi;