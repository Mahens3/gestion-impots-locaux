import { useCallback, useEffect } from 'react'
import { useState } from 'react'
import { useParams } from 'react-router-dom'
import axios from 'data/api/axios'
import { Spinner } from 'presentation/components/loader'
import { typeconstruction, typelogement, typeproprietaire } from 'data/constants/typedata'
import { ToastContainer } from 'react-toastify'

import 'react-toastify/dist/ReactToastify.css'
import 'bootstrap/dist/css/bootstrap.min.css'

import { formatter } from 'presentation/helpers/convertisseur'
import { Box, Typography, Grid, ButtonGroup, Button } from '@mui/material'
import apiUrl from 'core/api'

import Detail from "presentation/components/details"
import CardItem from './components/card'
import Header from 'presentation/components/header'

const AboutConstructionOut = () => {
    const { id } = useParams()
    const [construction, setConstruction] = useState()
    const [fieldConstruction, setFieldConstruction] = useState(typeconstruction)
    const [loading, setLoading] = useState(true)

    const [showDetail, setShowDetail] = useState(false)

    const getConstruction = useCallback(async (numcons = null) => {
        var response = await axios.get("/api/construction/" + (numcons === null ? id : numcons))
        let data = {
            "title": "Fokontany",
            "type": "select",
            "options": response.data.fokontany.map((value) => ({
                "id": value.id,
                "value": value.nomfokontany
            }))
        }
        setFieldConstruction((prevField) => ({
            ...prevField,
            "idfoko": data
        }))
        response.data = response.data.construction

        if (response.data.proprietaire === null) {
            response.data.proprietaire = {}
            Object.keys(typeproprietaire).forEach((value) => {
                response.data.proprietaire[value] = ""
            })
            response.data.proprietaire["numcons"] = response.data.numcons
        }

        if (response.data.logements === null) {
            response.data.logements = []
        }

        let logement = {}
        Object.keys(typelogement).forEach((value) => {
            if (typelogement[value].type === "field" || typelogement[value].type === "checkbox") {
                logement[value] = ""
            }
            else {
                logement[value] = typelogement[value].options[0]
            }
        })
        logement["numcons"] = response.data.numcons
        response.data.logements.push(logement)
        response.data.logs.push(logement)
        response.data.logs.map((item) => {
            if (item.confort === null) {
                item.confort = ""
            }
            return item
        })

        response.data.logements = response.data.logements.filter((logement) => logement !== null)
        setConstruction(response.data)
        setLoading(false)

    }, [id])

    useEffect(() => {
        getConstruction()
    }, [getConstruction])

    return (
        <>
            <Header />
            <ToastContainer position="top-right" autoClose={2000} />
            <Box
                mt={5}
                p={5}
            >
                {loading ? <Spinner /> :
                    <Box>
                        {
                            construction.numcons !== undefined &&
                            <Box
                                display="flex"
                                justifyContent="space-between"
                                alignItems="center"
                                mb={5}
                                flexDirection={{ xs: 'column', md: 'row' }}
                            >
                                <Box>
                                    <Box>
                                        <Typography variant='h5'>IFPB: {construction.impot !== null && formatter(construction.impot) + " Ariary"} </Typography> <Typography>ID: {construction.numcons}</Typography>
                                    </Box>
                                </Box>
                                <img style={{ marginTop: "10px", width: "300px", height: "280px", objectFit: "fill", borderRadius: 5, marginRight: 25, boxShadow: "0 4px 10px rgba(0, 0, 0, 0.5)" }} src={`${apiUrl}/api/image/${construction.image}`} alt="" />

                            </Box>
                        }
                        {
                            construction.numcons !== undefined &&
                            <Box
                                display="flex"
                                justifyContent="space-between"
                                alignItems="center"
                                mb={5}
                                flexDirection={{ xs: 'column', md: 'row' }}
                            >
                                <Box>
                                    <Box
                                        mb={2}
                                    >
                                        <ButtonGroup variant='contained' color='inherit' size='small' >
                                            <Button sx={{ textTransform: "none", pt: 1 }} onClick={() => { setShowDetail(!showDetail) }}>
                                                <Typography>Detail {showDetail ? "de la construction" : "du calcul"} </Typography>
                                            </Button>
                                        </ButtonGroup>
                                    </Box>
                                </Box>
                            </Box>
                        }
                        <Grid container spacing={2}>
                            {
                                showDetail ? (construction !== null && <>

                                    <Detail data={construction.logements} />

                                </>) :
                                    construction !== null &&
                                    <Grid item xs={12} sm={12} lg={12} md={12}>
                                        <CardItem
                                            data={construction}
                                            parameter={fieldConstruction}
                                            title="Construction"
                                            col={3}
                                        />
                                    </Grid>
                            }
                            {
                                construction.numcons !== undefined && !showDetail && <>

                                    <Grid item xs={12} sm={12} lg={12} md={12}>
                                        <CardItem
                                            data={construction.proprietaire}
                                            parameter={typeproprietaire}
                                            col={12}
                                            title="Propriétaire"
                                        />
                                    </Grid>
                                    {
                                        construction.logs.map(
                                            (value, key) =>
                                                <Grid item xs={12} sm={12} lg={12} md={12}>
                                                    <CardItem
                                                        key={key}
                                                        data={value}
                                                        col={3}
                                                        index={key}
                                                        parameter={typelogement}
                                                        title="Logement"
                                                    />
                                                </Grid>
                                        )
                                    }
                                </>
                            }
                        </Grid>
                    </Box>
                }
            </Box>
        </>
    )
}

export default AboutConstructionOut