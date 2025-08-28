import React, { useState } from "react";
import { useEffect } from "react";

import axios from "data/api/axios";

import { Box, Container, Grid, Paper, Typography } from "@mui/material";
import { FiberManualRecord, Folder, Home, Payments } from "@mui/icons-material";

import { BarChart, SplineChart } from "presentation/components/layout/chart";
import { formatter } from "presentation/helpers/convertisseur";
import { Spinner } from "presentation/components/loader"

const Dashboard = () => {
    const [data, setData] = useState({ "ready": false, "dataBar": [], "dataSpline": [], "construction": 0, "ifpb": 0, "paiement": 0 })
    const fetch = async () => {
        let response = await axios.get("api/dashboard")
        response.data["ready"] = true
        setData(response.data)
    }

    const Item = ({ item }) => {
        return (
            <Grid item xs={6} sm={6} md={6} lg={6}>
                <Box
                    display="flex"
                    justifyContent="flex-start"
                    fontWeight="bold"
                    fontSize="0.8rem"
                >
                    <FiberManualRecord
                        sx={{
                            mt: "5.5px",
                            mr: "4px",
                            fontSize: "0.5rem",
                            color: (item.y - item.z) > 0 ? "#5C9BA5" : "#429F5F"
                        }}
                    />
                    {item.fkt}
                </Box>
                <Box component="span" fontSize="0.8rem">
                    {(item.z * 100 / item.y).toFixed(2)}% ({formatter(item.y - item.z)} Ar)
                </Box>
            </Grid>)
    }

    useEffect(() => {
        fetch()
    }, [])

    return (
        <>
            <Container sx={{
                my: 5
            }}>
                {
                    data.ready ?
                        <>
                            <Grid container spacing={3}>
                                <Grid item xs={12} sm={12} md={4} lg={4}>
                                    <Paper
                                        elevation={0}
                                        sx={{
                                            p: 2,
                                            display: "flex",
                                            justifyContent: "flex-start",
                                            alignItems: "center",
                                            //boxShadow : "0 4px 10px rgba(0, 0, 0, 0.1)"
                                        }} >
                                        <Box
                                            p={2}
                                            borderRadius={50}
                                            bgcolor="#B2F2C6"
                                            mr={2}
                                        >
                                            <Home
                                                sx={{
                                                    color: "#429F5F"
                                                }}
                                            />
                                        </Box>
                                        <Box>
                                            <Typography>Total Construction</Typography>
                                            <Typography fontWeight="bold">{formatter(data.construction)} toit</Typography>
                                        </Box>
                                    </Paper>
                                </Grid>
                                <Grid item xs={12} sm={12} md={4} lg={4}>
                                    <Paper
                                        elevation={0}
                                        sx={{
                                            p: 2,
                                            display: "flex",
                                            justifyContent: "flex-start",
                                            alignItems: "center",
                                            //boxShadow : "0 4px 10px rgba(0, 0, 0, 0.1)"
                                        }} >
                                        <Box
                                            p={2}
                                            borderRadius={50}
                                            bgcolor="#B2E8F2"
                                            mr={2}
                                        >
                                            <Folder
                                                sx={{
                                                    color: "#5C9BA5"
                                                }}
                                            />
                                        </Box>
                                        <Box>
                                            <Typography>Total Ifpb</Typography>
                                            <Typography fontWeight="bold">{formatter(data.ifpb)} Ar</Typography>
                                        </Box>
                                    </Paper>
                                </Grid>
                                <Grid item xs={12} sm={12} md={4} lg={4}>
                                    <Paper
                                        elevation={0}
                                        sx={{
                                            p: 2,
                                            display: "flex",
                                            justifyContent: "flex-start",
                                            alignItems: "center",
                                            //boxShadow : "0 4px 10px rgba(0, 0, 0, 0.1)"
                                        }} >
                                        <Box
                                            p={2}
                                            borderRadius={50}
                                            bgcolor="#F0F2B2"
                                            mr={2}
                                        >
                                            <Payments
                                                sx={{
                                                    color: "#9FA153"
                                                }}
                                            />
                                        </Box>
                                        <Box>
                                            <Typography>Paiement Effectué</Typography>
                                            <Typography fontWeight="bold">{formatter(data.paiement)} Ar</Typography>
                                        </Box>
                                    </Paper>
                                </Grid>
                            </Grid>
                            <Grid container mt={2} spacing={3}>
                                <Grid item xs={12} sm={12} md={8} lg={8}>
                                    <Paper
                                        elevation={0}
                                        sx={{
                                            p: 2,

                                            //boxShadow : "0 4px 10px rgba(0, 0, 0, 0.1)"
                                        }} >
                                        <Box mb={2} ml={4}>
                                            <Typography fontWeight="bold">Diagramme en barre de l'IFPB et leur paiement respectif</Typography>
                                        </Box>
                                        <Box>
                                            <BarChart
                                                data={data.dataBar}
                                                title={["IFPB", "Paiement"]}
                                            />
                                        </Box>

                                    </Paper>
                                    <Paper
                                        elevation={0}
                                        sx={{
                                            mt : 3,
                                            p: 2,
                                            alignItems: "center",

                                            //boxShadow : "0 4px 10px rgba(0, 0, 0, 0.1)"
                                        }} >

                                        <Box mb={2} ml={4}>
                                            <Typography fontWeight="bold">Courbe du paiement de l'IFPB</Typography>
                                        </Box>
                                        <Box>
                                            <SplineChart
                                                data={data.dataSpline}
                                            />
                                        </Box>
                                    </Paper>
                                </Grid>
                                <Grid item xs={12} sm={12} md={4} lg={4}>
                                    <Paper
                                        elevation={0}
                                        sx={{
                                            p: 2,

                                            //boxShadow : "0 4px 10px rgba(0, 0, 0, 0.1)"
                                        }} >
                                        <Box mb={2}>
                                            <Typography fontWeight="bold">Pourcentage payé et reste à payé</Typography>
                                        </Box>
                                        <Grid container spacing={2}>
                                            {
                                                data.dataBar.map((item, index) => <Item key={index} item={item} />)
                                            }
                                        </Grid>
                                    </Paper>
                                </Grid>
                            </Grid>

                        </>
                        : <Spinner />
                }
            </Container>
        </>
    )
}

export default Dashboard
