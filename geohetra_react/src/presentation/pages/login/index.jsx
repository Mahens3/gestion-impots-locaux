import { useEffect, useState } from "react";
import * as Yup from "yup";
import {
  Alert,
  Box,
  Button,
  FormControlLabel,
  Stack,
  TextField,
  Typography,
} from "@mui/material";
import { Layout as AuthLayout } from "../../components/layout/auth";
import { useFormik } from "formik";
import { CheckBox, CheckBoxOutlineBlank } from "@mui/icons-material";
import useAuth from "./hook/useAuth";
import { ToastContainer } from "react-toastify";

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

  console.log("Formik data:", formik.values);
  console.log("Formik errors:", formik.errors);

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
                    <CheckBox sx={{ color: "green" }} />
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
              <Button
                fullWidth
                size="large"
                sx={{ mt: 3 }}
                color="success"
                type="submit"
                variant="contained"
              >
                {isLoading && <i className="fa fa-spin fa-spinner"></i>} Se
                connecter
              </Button>
              <Alert color="success" severity="info" sx={{ mt: 3 }}>
                <div>
                  Tous ces champs sont <b>obligatoire</b> donc vous devez{" "}
                  <b>les remplir.</b>
                </div>
              </Alert>
            </form>
          </div>
        </Box>
      </Box>
    </AuthLayout>
  );
};

export default LoginPage;
