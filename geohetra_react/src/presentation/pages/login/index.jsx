import { useEffect, useState } from 'react';
import * as Yup from 'yup';
import {
  Alert,
  Box,
  Button,
  FormControlLabel,
  Stack,
  TextField,
  Typography
} from '@mui/material';
import { Layout as AuthLayout } from '../../components/layout/auth';
import { useFormik } from 'formik';
import { CheckBox, CheckBoxOutlineBlank } from '@mui/icons-material';
import useAuth from './hook/useAuth';
import { ToastContainer } from 'react-toastify';


const LoginPage = () => {

  const formik = useFormik({
    initialValues: {
      email: '',
      password: '',
      submit: null
    },
    validationSchema: Yup.object({
      email: Yup
        .string()
        .max(255)
        .required('Identifiant requis'),
      password: Yup
        .string()
        .max(255)
        .required('Mot de passe requise')
    }),
    onSubmit: async (values, helpers) => {
      try {
        handleLogin(values, helpers)
      } catch (err) {
        helpers.setStatus({ success: false });
        helpers.setErrors({ submit: err.message });
        helpers.setSubmitting(false);
      }
    }
  })


  const { isLoading, handleLogin } = useAuth(formik.values, formik)

  const [show, setShow] = useState(false)

  const handleShow = (e) => {
    setShow(!show)
  }

  useEffect(() => {
    localStorage.removeItem("page")
    localStorage.removeItem("mode")
    localStorage.removeItem("search")
    localStorage.removeItem("token")
  }, [])


  return (
    <AuthLayout>
      <ToastContainer limit={2000} position='top-right' />
      <Box
        sx={{
          backgroundColor: 'background.paper',
          flex: '1 1 auto',
          alignItems: 'center',
          display: 'flex',
          justifyContent: 'center'
        }}
      >
        <Box
          sx={{
            maxWidth: 550,
            px: 3,
            py: '100px',
            width: '100%'
          }}
        >
          <div>
            <Stack
              spacing={1}
              sx={{ mb: 3 }}
            >
              <Typography variant="h4">
                Identifiez-vous
              </Typography>
              <Typography
                color="text.secondary"
                variant="body2"
              >
                Vous devez entrez votre identifiant et mot de passe pour profiter l'application
              </Typography>
            </Stack>

            <form
              noValidate
              onSubmit={formik.handleSubmit}
            >
              <Stack spacing={3}>
                <TextField
                  error={!!(formik.touched.email && formik.errors.email)}
                  fullWidth
                  helperText={formik.touched.email && formik.errors.email}
                  label="Identifiant"
                  name="email"
                  onBlur={formik.handleBlur}
                  onChange={formik.handleChange}
                  type="text"
                  value={formik.values.email}
                />
                <TextField
                  error={!!(formik.touched.password && formik.errors.password)}
                  fullWidth
                  helperText={formik.touched.password && formik.errors.password}
                  label="Mot de passe"
                  name="password"
                  onBlur={formik.handleBlur}
                  onChange={formik.handleChange}
                  type={show ? "text" : "password"}
                  value={formik.values.password}
                />
              </Stack>
              <FormControlLabel
                sx={{
                  m: 1
                }}
                label="Afficher mot de passe"
                checked={show}
                onClick={handleShow}
                control={show ? <CheckBox sx={{ color: "green" }} /> : <CheckBoxOutlineBlank />}
              />
              {formik.errors.submit && (
                <Typography
                  color="error"
                  sx={{ mt: 3 }}
                  variant="body2"
                >
                  {formik.errors.submit}
                </Typography>
              )}
              <Button
                fullWidth
                size="large"
                sx={{ mt: 3 }}
                color='success'
                type="submit"
                variant="contained"
              >
                {isLoading && <i className='fa fa-spin fa-spinner'></i>}  Se connecter
              </Button>
              <Alert
                color="success"
                severity="info"
                sx={{ mt: 3 }}
              >
                <div>
                  Tous ces champs sont <b>obligatoire</b> donc vous devez <b>les remplir.</b>
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
