import { useEffect, useState } from "react";
import * as Yup from "yup";
import {
  Box,
  Button,
  FormControlLabel,
  Stack,
  TextField,
  Typography,
} from "@mui/material";
import { Layout as AuthLayout } from "../../components/layout/auth";
import { useFormik } from "formik";
import { CheckBox, CheckBoxOutlineBlank, Info } from "@mui/icons-material";
import useAuth from "./hook/useAuth";
import { ToastContainer } from "react-toastify";
import LoginIcon from "@mui/icons-material/Login";
import { alpha } from "@mui/material/styles";
import { CircularProgress } from "@mui/material";

const LoginPage = () => {
  const formik = useFormik({
    initialValues: {
      phone: "",
      password: "",
      submit: null,
    },
    validationSchema: Yup.object({
      phone: Yup.string().max(255).required("Identifiant requis"),
      mdp: Yup.string().max(255).required("Mot de passe requise"),
    }),
    onSubmit: async (values, helpers) => {
      try {
        handleLogin(values, helpers);
      } catch (err) {
        helpers.setStatus({ success: false });
        helpers.setErrors({ submit: err.message });
        helpers.setSubmitting(false);
      }
    },
  });

  const { isLoading, handleLogin } = useAuth(formik.values, formik);

  const [show, setShow] = useState(false);

  const handleShow = (e) => {
    setShow(!show);
  };

  useEffect(() => {
    localStorage.removeItem("page");
    localStorage.removeItem("mode");
    localStorage.removeItem("search");
    localStorage.removeItem("token");
  }, []);

  return (
    <AuthLayout>
      <ToastContainer limit={2000} position="top-right" />
      <Box
        sx={{
          backgroundColor: "background.paper",
          flex: "1 1 auto",
          alignItems: "center",
          display: "flex",
          justifyContent: "center",
        }}
      >
        <Box
          sx={{
            maxWidth: 550,
            px: 3,
            py: "100px",
            width: "100%",
          }}
        >
          <div>
            <Stack spacing={1} sx={{ mb: 3 }}>
              <Typography variant="h4">Identifiez-vous</Typography>
              <Typography color="text.secondary" variant="body2">
                Vous devez entrez votre identifiant et mot de passe pour
                profiter l'application
              </Typography>
            </Stack>

            <form noValidate onSubmit={formik.handleSubmit}>
              <Stack spacing={3}>
                <TextField
                  error={!!(formik.touched.phone && formik.errors.phone)}
                  fullWidth
                  helperText={formik.touched.phone && formik.errors.phone}
                  label="Identifiant"
                  name="phone"
                  onBlur={formik.handleBlur}
                  onChange={formik.handleChange}
                  type="tel"
                  value={formik.values.phone}
                />
                <TextField
                  error={!!(formik.touched.mdp && formik.errors.mdp)}
                  fullWidth
                  helperText={formik.touched.mdp && formik.errors.mdp}
                  label="Mot de passe"
                  name="mdp"
                  onBlur={formik.handleBlur}
                  onChange={formik.handleChange}
                  type={show ? "text" : "password"}
                  value={formik.values.mdp}
                />
              </Stack>
              <FormControlLabel
                sx={{
                  m: 1,
                }}
                label="Afficher mot de passe"
                checked={show}
                onClick={handleShow}
                control={
                  show ? (
                    <CheckBox sx={{ color: "#1e40af" }} />
                  ) : (
                    <CheckBoxOutlineBlank />
                  )
                }
              />
              {formik.errors.submit && (
                <Typography color="error" sx={{ mt: 3 }} variant="body2">
                  {formik.errors.submit}
                </Typography>
              )}
              {/* Submit Button */}
              <Button
                fullWidth
                type="submit"
                variant="contained"
                disabled={isLoading}
                startIcon={
                  isLoading ? (
                    <CircularProgress size={20} sx={{ color: "#ffffff" }} />
                  ) : (
                    <LoginIcon />
                  )
                }
                sx={{
                  bgcolor: "#1e40af",
                  color: "#ffffff",
                  fontWeight: 600,
                  textTransform: "none",
                  py: { xs: 1.5, sm: 1.75 },
                  fontSize: { xs: "0.95rem", sm: "1rem" },
                  borderRadius: 1.5,
                  boxShadow: `0 4px 12px ${alpha("#1e40af", 0.4)}`,
                  "&:hover": {
                    bgcolor: "#1e3a8a",
                    boxShadow: `0 6px 16px ${alpha("#1e40af", 0.5)}`,
                    transform: "translateY(-2px)",
                  },
                  "&:disabled": {
                    bgcolor: alpha("#1e40af", 0.6),
                    color: "#ffffff",
                  },
                  transition: "all 0.3s ease",
                }}
              >
                {isLoading ? "Connexion en cours..." : "Se connecter"}
              </Button>

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
                <Info sx={{ color: '#2563eb', fontSize: '1.25rem', flexShrink: 0, mt: 0.25 }} />
                <Typography
                  variant="body2"
                  sx={{
                    color: alpha('#1e293b', 0.7),
                    fontSize: { xs: '0.8rem', sm: '0.85rem' },
                    lineHeight: 1.6
                  }}
                >
                  Tous les champs sont <strong>obligatoires</strong> pour vous connecter.
                </Typography>
              </Box>
            </form>
          </div>
        </Box>
      </Box>
    </AuthLayout>
  );
};

export default LoginPage;
