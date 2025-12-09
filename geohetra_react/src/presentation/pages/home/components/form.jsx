// ========== FORM COMPONENT ==========
import {
  Box,
  Button,
  TextField,
  Typography,
  Paper,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  alpha,
  CircularProgress,
//   useTheme,
//   useMediaQuery,
  InputAdornment
} from "@mui/material";
import { useFormik } from "formik";
import useFokontany from "presentation/hooks/useFokontany";
import { useEffect, useState } from "react";
import { 
  Info, 
  Search, 
  Home as HomeIcon,
} from "@mui/icons-material";
import * as Yup from "yup";

const Form = ({ currentPage, isLoading, handleSearch }) => {
//   const theme = useTheme();
//   const isMobile = useMediaQuery(theme.breakpoints.down('sm'));
  const fokontany = useFokontany();
  const [selectedFkt, setSelectedFkt] = useState();

  useEffect(() => {
    if (fokontany.length > 0) {
      setSelectedFkt(fokontany[0].id);
    }
  }, [fokontany]);

  const formik = useFormik({
    initialValues: {
      nom: "",
      prenom: "",
      adresse: "",
      submit: null,
    },
    validationSchema: Yup.object({
      nom: Yup.string().max(255).required("Nom requis"),
    }),
    onSubmit: async (values, helpers) => {
      try {
        handleSearch({
          ...values,
          idfoko: selectedFkt,
          page: currentPage,
        });
      } catch (err) {
        helpers.setStatus({ success: false });
        helpers.setErrors({ submit: err.message });
        helpers.setSubmitting(false);
      }
    },
  });

  return (
    <Paper
      elevation={0}
      sx={{
        maxWidth: 600,
        width: '100%',
        p: { xs: 3, sm: 4 },
        borderRadius: 3,
        border: `1px solid ${alpha('#000', 0.08)}`,
        bgcolor: '#ffffff',
        boxShadow: '0 8px 24px rgba(0, 0, 0, 0.08)'
      }}
    >
      {/* Header */}
      <Box sx={{ mb: 3 }}>
        <Typography
          variant="h5"
          sx={{
            fontWeight: 700,
            color: '#1e293b',
            fontSize: { xs: '1.25rem', sm: '1.5rem' },
            mb: 1
          }}
        >
          Rechercher une construction
        </Typography>
        <Typography
          variant="body2"
          sx={{
            color: alpha('#1e293b', 0.6),
            fontSize: { xs: '0.85rem', sm: '0.9rem' },
            lineHeight: 1.6
          }}
        >
          Consultez les impôts fonciers sur les propriétés bâties en remplissant le formulaire ci-dessous
        </Typography>
      </Box>

      {/* Form */}
      <form noValidate onSubmit={formik.handleSubmit}>
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2.5 }}>
          {/* Nom */}
          <TextField
            fullWidth
            label="Nom *"
            name="nom"
            type="text"
            value={formik.values.nom}
            onChange={formik.handleChange}
            onBlur={formik.handleBlur}
            error={!!(formik.touched.nom && formik.errors.nom)}
            helperText={formik.touched.nom && formik.errors.nom}
 
            sx={{
              '& .MuiOutlinedInput-root': {
                borderRadius: 1.5,
                '&:hover .MuiOutlinedInput-notchedOutline': {
                  borderColor: alpha('#1e40af', 0.3)
                },
                '&.Mui-focused .MuiOutlinedInput-notchedOutline': {
                  borderColor: '#1e40af',
                  borderWidth: '2px'
                }
              },
              '& .MuiInputLabel-root.Mui-focused': {
                color: '#1e40af'
              }
            }}
          />

          {/* Prénoms */}
          <TextField
            fullWidth
            label="Prénoms"
            name="prenom"
            type="text"
            value={formik.values.prenom}
            onChange={formik.handleChange}
            onBlur={formik.handleBlur}
            error={!!(formik.touched.prenom && formik.errors.prenom)}
            helperText={formik.touched.prenom && formik.errors.prenom}
            sx={{
              '& .MuiOutlinedInput-root': {
                borderRadius: 1.5,
                '&:hover .MuiOutlinedInput-notchedOutline': {
                  borderColor: alpha('#1e40af', 0.3)
                },
                '&.Mui-focused .MuiOutlinedInput-notchedOutline': {
                  borderColor: '#1e40af',
                  borderWidth: '2px'
                }
              },
              '& .MuiInputLabel-root.Mui-focused': {
                color: '#1e40af'
              }
            }}
          />

          {/* Adresse */}
          <TextField
            fullWidth
            label="Adresse"
            name="adresse"
            type="text"
            value={formik.values.adresse}
            onChange={formik.handleChange}
            onBlur={formik.handleBlur}
            error={!!(formik.touched.adresse && formik.errors.adresse)}
            helperText={formik.touched.adresse && formik.errors.adresse}
            sx={{
              '& .MuiOutlinedInput-root': {
                borderRadius: 1.5,
                '&:hover .MuiOutlinedInput-notchedOutline': {
                  borderColor: alpha('#1e40af', 0.3)
                },
                '&.Mui-focused .MuiOutlinedInput-notchedOutline': {
                  borderColor: '#1e40af',
                  borderWidth: '2px'
                }
              },
              '& .MuiInputLabel-root.Mui-focused': {
                color: '#1e40af'
              }
            }}
          />

          {/* Fokontany Select */}
          <FormControl 
            fullWidth
            sx={{
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
                '&.Mui-focused': {
                  color: '#1e40af'
                }
              }}
            >
              Fokontany *
            </InputLabel>
            <Select
              value={selectedFkt || ''}
              label="Fokontany *"
              onChange={(e) => setSelectedFkt(e.target.value)}
              startAdornment={
                <InputAdornment position="start">
                  <HomeIcon sx={{ color: alpha('#1e293b', 0.5) }} />
                </InputAdornment>
              }
            >
              {fokontany?.map((value) => (
                <MenuItem 
                  key={value.id} 
                  value={value.id}
                  sx={{
                    '&:hover': {
                      bgcolor: alpha('#1e40af', 0.08)
                    }
                  }}
                >
                  {value.nomfokontany}
                </MenuItem>
              ))}
            </Select>
          </FormControl>

          {/* Submit Button */}
          <Button
            fullWidth
            type="submit"
            variant="contained"
            disabled={isLoading}
            startIcon={
              isLoading ? (
                <CircularProgress size={20} sx={{ color: '#ffffff' }} />
              ) : (
                <Search />
              )
            }
            sx={{
              bgcolor: '#1e40af',
              color: '#ffffff',
              fontWeight: 600,
              textTransform: 'none',
              py: { xs: 1.5, sm: 1.75 },
              fontSize: { xs: '0.95rem', sm: '1rem' },
              borderRadius: 1.5,
              boxShadow: `0 4px 12px ${alpha('#1e40af', 0.4)}`,
              '&:hover': {
                bgcolor: '#1e3a8a',
                boxShadow: `0 6px 16px ${alpha('#1e40af', 0.5)}`,
                transform: 'translateY(-2px)'
              },
              '&:disabled': {
                bgcolor: alpha('#1e40af', 0.6),
                color: '#ffffff'
              },
              transition: 'all 0.3s ease'
            }}
          >
            {isLoading ? 'Recherche en cours...' : 'Rechercher'}
          </Button>

          {/* Info Box */}
          <Box
            sx={{
              p: 2,
              borderRadius: 1.5,
              bgcolor: alpha('#3b82f6', 0.08),
              border: `1px solid ${alpha('#3b82f6', 0.2)}`,
              display: 'flex',
              gap: 1.5,
              alignItems: 'flex-start'
            }}
          >
            <Info
              sx={{
                color: '#2563eb',
                fontSize: '1.25rem',
                flexShrink: 0,
                mt: 0.25
              }}
            />
            <Typography
              variant="body2"
              sx={{
                color: alpha('#1e293b', 0.7),
                fontSize: { xs: '0.8rem', sm: '0.85rem' },
                lineHeight: 1.6
              }}
            >
              Les champs <strong>Nom</strong> et <strong>Fokontany</strong> sont obligatoires pour effectuer la recherche.
            </Typography>
          </Box>
        </Box>
      </form>
    </Paper>
  );
};

export default Form;