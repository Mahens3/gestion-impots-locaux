import { Alert, Box, Button, Stack, TextField, Typography } from '@mui/material';
import { useFormik } from 'formik';
import useFokontany from 'presentation/hooks/useFokontany';
import { useEffect, useState } from 'react';

import * as Yup from 'yup';

const Form = ({ currentPage, isLoading, handleSearch}) => {
    const fokontany = useFokontany()
    const [selectedFkt, setSelectedFkt] = useState()

    useEffect(() => {
        if (fokontany.length > 0) {
            setSelectedFkt(fokontany[0].id)
        }
    }, [fokontany])

    const formik = useFormik({
        initialValues: {
            nom: '',
            prenom: '',
            adresse: '',
            submit: null
        },
        validationSchema: Yup.object({
            nom: Yup
                .string()
                .max(255)
                .required('Nom requis'),
        }),
        onSubmit: async (values, helpers) => {
            try {
                handleSearch({
                    ...values,
                    "idfoko" : selectedFkt,
                    "page" : currentPage
                })
            } catch (err) {
                helpers.setStatus({ success: false });
                helpers.setErrors({ submit: err.message });
                helpers.setSubmitting(false);
            }
        }
    })

    return (
        <Box
            sx={{
                alignItems: 'center',
                display: 'flex',
                justifyContent: 'center'
            }}
        >
            <Box
                sx={{
                    maxWidth: 550,
                    px: 5,
                    py: 5,
                    backgroundColor: "#fff",
                    width: '100%'
                }}
            >
                <div>
                    <Stack
                        spacing={1}
                        sx={{ mb: 3 }}
                    >
                        <Typography variant="h4">
                            Bienvenue sur Geohetra
                        </Typography>
                        <Typography
                            color="text.secondary"
                            variant="body2"
                        >
                            Site web pour la consultation d'impot foncier sur les propriétés bâtis.
                            Remplissez la formulaire suivant :
                        </Typography>
                    </Stack>

                    <form
                        noValidate
                        onSubmit={formik.handleSubmit}
                        
                    >
                        <Stack spacing={3}>
                            <TextField
                                error={!!(formik.touched.nom && formik.errors.nom)}
                                fullWidth
                                helperText={formik.touched.nom && formik.errors.nom}
                                label="Nom"
                                name="nom"
                                onBlur={formik.handleBlur}
                                onChange={formik.handleChange}
                                type="text"
                                value={formik.values.nom}
                            />
                            <TextField
                                error={!!(formik.touched.prenom && formik.errors.prenom)}
                                fullWidth
                                helperText={formik.touched.prenom && formik.errors.prenom}
                                label="Prénoms"
                                name="prenom"
                                onBlur={formik.handleBlur}
                                onChange={formik.handleChange}
                                type="text"
                                value={formik.values.email}
                            />
                            <TextField
                                error={!!(formik.touched.adresse && formik.errors.adresse)}
                                fullWidth
                                helperText={formik.touched.adresse && formik.errors.adresse}
                                label="Adresse"
                                name="adresse"
                                onBlur={formik.handleBlur}
                                onChange={formik.handleChange}
                                type="text"
                                value={formik.values.password}
                            />
                            <div>
                                <label htmlFor="">Selectionnez un fokontany</label>
                                <select
                                    value={selectedFkt}
                                    style={{
                                        height: 50
                                    }}
                                    className='form-control'
                                    onChange={(e) => { setSelectedFkt(e.target.value) }}
                                >
                                    {
                                        fokontany.map((value) => (
                                            <option value={value.id}>
                                                {value.nomfokontany}
                                            </option>
                                        ))
                                    }
                                </select>
                            </div>

                        </Stack>
                        <Button
                            fullWidth
                            size="large"
                            sx={{ mt: 3 }}
                            color='success'
                            type="submit"
                            disabled={isLoading}
                            variant="contained"
                        >
                            { isLoading && <i className='fa fa-spin fa-spinner'></i>  } Rechercher
                        </Button>
                        <Alert
                            color="success"
                            severity="info"
                            sx={{ mt: 3 }}
                        >
                            <div>
                                Le champ nom et fokontany sont <b>obligatoire</b> donc vous devez <b>les remplir.</b>
                            </div>
                        </Alert>
                    </form>
                </div>
            </Box>
        </Box >
    )
}

export default Form