import { Box, SpeedDial, SpeedDialAction } from "@mui/material"
import { createContext, useEffect, useRef, useState } from "react"

import 'leaflet.markercluster'
import "leaflet/dist/leaflet.css"
import 'react-leaflet-markercluster/dist/styles.min.css'

import "presentation/assets/style/leaflet.css"
import { MapContainer, Polygon, Polyline, TileLayer, useMapEvent } from "react-leaflet"
import {  Close, Home, Reddit, Settings } from "@mui/icons-material"

import * as turf from 'turf' // Import de Turf.js

const MapContext = createContext()
const initialCenter = [-21.83083, 46.932005]

const Map = () => {
    const [construction, setConstruction] = useState([])
    const [isDrawing, setIsDrawing] = useState(false)
    const [center, setCenter] = useState(initialCenter)
    const [polygonArea, setPolygonArea] = useState(null)


    const mapRef = useRef()

    const handleCancel = () => {
        setIsDrawing(false)
        setConstruction([])
        setPolygonArea(null)
    }

    const handleReset = () => {
        setIsDrawing(true)
        setPolygonArea(null)
        setConstruction([])
    }

    const handleFinish = () => {
        setIsDrawing(false);
    
        if (construction.length < 3) {
            setPolygonArea(null);
            return;
        }
    
        const coords = construction.map(latlng => [latlng.lng, latlng.lat]);
    
        const closedCoords = [...coords, coords[0]];
    
        const polygon = turf.polygon([closedCoords]);
    
        const area = turf.area(polygon);
        setPolygonArea(area);
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

    return (
        <>
            <SpeedDial
                ariaLabel='Gestion de la carte'
                sx={{
                    position: "absolute",
                    bottom: 16,
                    right: 16,
                }}
                icon={<Settings />}
            >
                <SpeedDialAction icon={<Home />} onClick={handleFinish} tooltipTitle={"Assembler"} />
                <SpeedDialAction icon={<Close />} onClick={handleCancel} tooltipTitle={"Annuler"} />
                <SpeedDialAction icon={<Reddit />} onClick={handleReset} tooltipTitle={"Retracer la construction"} />
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
            {polygonArea !== null && (
                <Box sx={{ position: 'absolute', bottom: 50, right: 20, backgroundColor: 'white', padding: '5px' }}>
                    Surface du polygone : {polygonArea.toFixed(2)} m²
                </Box>
            )}
        </>
    )
}

const Distribution = () => {
    return (
        <>
            <Box
                sx={{
                    width: 100
                }}
            >
                <MapContext.Provider>
                    <Map />
                </MapContext.Provider>
            </Box>
        </>
    )
}

export default Distribution
