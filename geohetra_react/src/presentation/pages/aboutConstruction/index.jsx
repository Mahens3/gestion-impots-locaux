import { useCallback, useRef } from 'react'
import { useEffect } from 'react'
import { useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import axios from 'data/api/axios'
import { Spinner } from 'presentation/components/loader'
import { typeconstruction, typelogement, typeproprietaire } from 'data/constants/typedata'
import { ToastContainer, toast } from 'react-toastify'

import 'react-toastify/dist/ReactToastify.css'
import 'bootstrap/dist/css/bootstrap.min.css'

import * as turf from "turf"

import { formatter } from 'presentation/helpers/convertisseur'
import { Table } from 'presentation/components/table'
import { Box, Button, ButtonGroup, Typography, Grid } from '@mui/material'
import { ModalPayment } from 'presentation/components/modal/modal'
import apiUrl from 'core/api'

import Formulaire from "./components/formulaire"
import Detail from "presentation/components/details"

const AboutConstruction = () => {
    const { id, geometry } = useParams()
    const [construction, setConstruction] = useState()
    const [fieldConstruction, setFieldConstruction] = useState(typeconstruction)
    const [loading, setLoading] = useState(true)

    const [selectedPayment, setSelectedPayment] = useState()
    const [selectedIndex, setSelectedIndex] = useState()
    const [modal, setModal] = useState(false)
    const [payments, setPayments] = useState([])
    const [showDetail, setShowDetail] = useState(false)

    const navigation = useNavigate()

    const totalPayement = useCallback(() => {
        let paie = 0
        payments.forEach((value) => {
            paie += value.montant
        })
        return paie
    }, [payments])

    const actionPayment = (index, data) => {
        return (
            <td style={{ borderBottom: "1px solid #DFDFDF" }}>
                <button className='btn btn-success'
                    onClick={() => {
                        setSelectedPayment(data)
                        setSelectedIndex(index)
                        setModal(true)
                    }}
                > <i className='fa fa-pencil'></i> </button>
            </td>
        )
    }

    const handlePayment = (index, value) => {
        let payes = [...payments]
        if (index === null) {
            payes.push(value)
        }
        else {
            payes[index] = value
        }
        setPayments(payes)
    }

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
        if (response.data === null) {
            const calque = Object.keys(typeconstruction)
                .reduce((accumulator, key) => {
                    return {
                        ...accumulator,
                        [key]: typeconstruction[key]["type"] === "select" ? typeconstruction[key]["options"][0] : ""
                    }
                }, {})

            let geom = JSON.parse(geometry)
            geom = geom.map((coord) => [coord.lat, coord.lng])
            geom.push(geom[0])
            calque["geometry"] = JSON.stringify(geom)
            calque["coord"] = `${geom[0][0]}, ${geom[0][1]}`
            let polygon = turf.polygon([geom])
            let surface = turf.area(polygon)
            calque["idfoko"] = data.options[0]["id"]
            calque["surface"] = surface.toFixed(2)
            setConstruction(calque)
        }
        else {
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
            setPayments(response.data.payments)
            setConstruction(response.data)
        }
        setLoading(false)

    }, [id, geometry])

    useEffect(() => {
        getConstruction()
    }, [getConstruction])

    const fileRef = useRef()
    const [file, setFile] = useState()

    const handleImageChange = async (e) => {
        let form = new FormData()

        form.append("image", e.target.files[0])
        form.append("numcons", construction.numcons)
        await axios.post("/api/addimage", form)
            .then((response) => {
                toast.success("Image changé")
                setFile(e.target.files[0])
            })
    }

    return (
        <>
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
                                    <Box
                                        mb={2}
                                    >
                                        <ButtonGroup variant='contained' color='inherit' size='small' >
                                            <Button sx={{ textTransform: "none", pt: 1 }} onClick={() => { fileRef.current.click() }} >
                                                <Typography>Changer image</Typography>
                                            </Button>
                                            <Button sx={{ textTransform: "none", pt: 1 }} onClick={() => { setShowDetail(!showDetail) }}>
                                                <Typography>Detail {showDetail ? "de la construction" : "du calcul"} </Typography>

                                            </Button>

                                            <Button sx={{ textTransform: "none", pt: 1 }} onClick={() => {
                                                navigation("/avis/" + (construction.numcons || id))
                                            }}>
                                                <Typography>Voir avis d'imposition </Typography>
                                            </Button>
                                        </ButtonGroup>
                                    </Box>
                                    <Box>
                                        <Typography variant='h5'>IFPB: {construction.impot !== null && formatter(construction.impot) + " Ariary"} </Typography> <Typography>ID: {construction.numcons}</Typography>

                                        <Box>
                                            Loyer mensuel:  {construction.loyer}
                                        </Box>
                                    </Box>

                                </Box>
                                <img
                                    style={{
                                        marginTop: "10px",
                                        width: "300px",
                                        height: "280px",
                                        objectFit: "fill",
                                        borderRadius: 5,
                                        marginRight: 25,
                                        boxShadow: "0 4px 10px rgba(0, 0, 0, 0.5)",
                                    }}
                                    src={
                                        file instanceof File
                                            ? URL.createObjectURL(file)
                                            : `${apiUrl}/api/image/${construction.image}`
                                    }
                                    alt="construction"
                                />
                                <input onChange={handleImageChange} accept='image/*' ref={fileRef} type='file' style={{ display: "none" }} />

                            </Box>
                        }
                        <Grid container spacing={2}>
                            {
                                showDetail ? (construction !== null && <>

                                    <Detail data={construction.logements} />

                                </>) :
                                    construction !== null &&
                                    <Grid item xs={12} sm={12} lg={12} md={12}>
                                        <Formulaire
                                            icon="fa fa-home"
                                            id="numcons"
                                            data={construction}
                                            parameter={fieldConstruction}
                                            file={file}
                                            title="Construction"
                                            col={3}
                                            refresh={getConstruction}
                                            url="/construction"
                                        />
                                    </Grid>
                            }
                            {
                                construction.numcons !== undefined && !showDetail && <>

                                    <Grid item xs={12} sm={12} lg={12} md={12}>
                                        <Formulaire
                                            icon="fa fa-user"
                                            id="numprop"
                                            data={construction.proprietaire}
                                            parameter={typeproprietaire}
                                            refresh={getConstruction}
                                            col={12}
                                            title="Propriétaire"
                                            url="/proprietaire"
                                        />
                                    </Grid>
                                    {
                                        construction.logs.map(
                                            (value, key) =>

                                                <Grid item xs={12} sm={12} lg={12} md={12}>
                                                    <Formulaire
                                                        id="numlog"
                                                        icon="fa fa-folder"
                                                        key={key}
                                                        data={value}
                                                        col={3}
                                                        index={key}
                                                        parameter={typelogement}
                                                        refresh={getConstruction}
                                                        title="Logement"
                                                        url="/logement"
                                                    />
                                                </Grid>
                                        )
                                    }
                                    <Grid item xs={12} sm={12} lg={12} md={12}>
                                        <Typography variant='h6' sx={{
                                            mb: 1,
                                            fontWeight: "bold"
                                        }}>Paiement effectué</Typography>
                                        {modal && <ModalPayment resteApaye={parseInt((construction.impot)) - totalPayement()} state={selectedPayment} setState={handlePayment} index={selectedIndex} numcons={construction.numcons} closeModal={() => { setModal(!modal) }} />}
                                        <Table
                                            add={() => { setModal(true) }}
                                            colaction={actionPayment}
                                            withIndex={true}
                                            keys={["quittance", "montant", "datePayment", "timePayment"]}
                                            title={["Quittance", "Montant", "Date paiement", "Heure paiement"]}
                                            rows={payments}
                                        />
                                    </Grid>
                                </>
                            }
                        </Grid>
                    </Box>
                }
            </Box>
        </>
    )
}

export default AboutConstruction