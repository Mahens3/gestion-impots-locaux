import { Box, SpeedDial, SpeedDialAction } from "@mui/material"
import Layout from "presentation/components/layout/layout"

import { createContext, useContext, useEffect, useRef, useState } from "react"
import { useNavigate, useParams } from "react-router-dom"


import L from 'leaflet'
import 'leaflet.markercluster'
import "leaflet/dist/leaflet.css"
import 'react-leaflet-markercluster/dist/styles.min.css'

import "presentation/assets/style/leaflet.css"

import { MapContainer, Polygon, Polyline, TileLayer, useMapEvent } from "react-leaflet"
import { Add, Close, Home, Reddit, Settings } from "@mui/icons-material"

import baseUrl from "core/basename"
import useFokontany from "presentation/hooks/useFokontany"
import useConstructionList from "presentation/hooks/useConstructionList"

const MapContext = createContext()
const initialCenter = [-21.83083, 46.932005]

const Map = () => {
    const { numcons } = useParams()
    const context = useContext(MapContext)
    const data = context.data

    const [construction, setConstruction] = useState([])
    const [isDrawing, setIsDrawing] = useState(false)
    const [center, setCenter] = useState(initialCenter)

    const mapRef = useRef()

    const navigation = useNavigate()

    const handleConstruction = () => {
        if (isDrawing) {
            navigation("/construction/new/" + JSON.stringify(construction))
        }
        setIsDrawing(!isDrawing)
    }

    const handleCancel = () => {
        setIsDrawing(false)
        setConstruction([])
    }

    const handleReset = () => {
        setIsDrawing(false)
    }

    const handleMapClick = (e) => {
        if (isDrawing) {
            setConstruction([...construction, e.latlng])
        }
    }

    const MapEvents = () => {
        useMapEvent({
            click: handleMapClick,
        })

        return null
    }

    useEffect(() => {
        if (data.length > 0) {
            setCenter(data[0].position)
        }
    }, [data])

    useEffect(() => {

        const markers = L.markerClusterGroup({
            disableClusteringAtZoom: 18,
        })

        data.forEach((value) => {
            const customMarkerIcon = L.divIcon({
                className: `custom-icon ${numcons == value.numcons ? 'text-danger' : 'text-success'} `,
                html: '<i class="fa fa-home"></i>',
                iconSize: [30, 30],
            })
            const marker = L.marker(value.position, { icon: customMarkerIcon })
            
            const customPopup = `
                <div class='d-flex'>
                    <div>
                        <img class='img-marker' src='${baseUrl}/api/image/${value.image}' />
                    </div>

                    <div >
                        <span class='ref' >ID: ${value.numcons}</span><br>
                        <span class='fw-bold' >${value.proprietaire}</span><br>
                        <span class='fw-bold' >${value.surface} m²</span><br>
                        <span> Adresse: ${value.adresse || ''} ${value.boriboritany || ''} ${value.fokontany}</span><br>
                        <span>Article: ${value.article || 'Inconnu'}</span><br>
                        <span>IFPB : ${value.impot}</span><br>
                        <a class='btn-link fw-bold' href="/construction/${value.numcons}">Voir plus </a>
                    <div >
                </div>
                `

            marker.bindPopup(customPopup)
            markers.addLayer(marker)
        })

        if (mapRef.current !== null) {
            mapRef.current.addLayer(markers)
        }

    }, [data])

    return (
        <>
            <div className="fkt">
                <div>
                    fokontany:
                </div>
                <select
                    className="form-select"
                    value={context.selectedFokontany}
                    onChange={(e) => {
                        context.setSelectedFokontany(e.target.value)
                    }}
                >
                    {context.fokontanyList.map(
                        (fokontany, key) =>
                            <option
                                value={fokontany.id} key={key}>
                                {fokontany.nomfokontany}
                            </option>
                    )}
                </select>
            </div>
            <SpeedDial
                ariaLabel='Gestion de la carte'
                sx={{
                    position: "absolute",
                    bottom: 16,
                    right: 16,
                }}
                icon={<Settings />}
            >
                {isDrawing && <SpeedDialAction icon={<Close />} onClick={handleCancel} tooltipTitle={"Annuler"} />}
                {isDrawing && <SpeedDialAction icon={<Reddit />} onClick={handleReset} tooltipTitle={"Retracer la construction"} />}
                <SpeedDialAction icon={isDrawing ? <Add /> : <Home />} onClick={handleConstruction} tooltipTitle={isDrawing ? "Faire l'autodeclaration" : "Tracer la construction"} />
            </SpeedDial>
            <MapContainer
                center={center}
                zoom={16}
                ref={mapRef}
            >
                <TileLayer
                    url='https://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}'
                    maxZoom={20}
                    subdomains={['mt1', 'mt2', 'mt3']}
                />

                <MapEvents />

                {
                    isDrawing ?
                        <Polyline
                            positions={construction}
                            color="blue"
                            fillColor="blue"
                            fillOpacity={0.4}
                        /> :
                        <Polygon
                            positions={construction}
                            color="blue"
                            fillColor="blue"
                            fillOpacity={0.4}
                        />
                }
            </MapContainer>

        </>
    )
}


const Carte = () => {
    const { idfoko } = useParams()
    const fokontanyList = useFokontany()
    const { data, selectedFokontany, setSelectedFokontany } = useConstructionList()

    useEffect(() => {
        if (idfoko) {
            setSelectedFokontany(idfoko)
        }
    }, [])

    return (
        <>
            <Box
                sx={{
                    width: 100
                }}
            >
                <MapContext.Provider value={{
                    data,
                    selectedFokontany,
                    setSelectedFokontany,
                    fokontanyList
                }}>
                    <Map data={data} />
                </MapContext.Provider>
            </Box>
        </>
    )
}
export default Carte
