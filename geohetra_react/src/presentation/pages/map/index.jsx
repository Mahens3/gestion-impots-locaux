import { 
  Box, 
  SpeedDial, 
  SpeedDialAction,
  Paper,
  FormControl,
  Select,
  MenuItem,
  InputLabel,
  Chip,
  alpha,
  useTheme,
  useMediaQuery,
} from "@mui/material";
import { createContext, useContext, useEffect, useRef, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";

import L from 'leaflet';
import 'leaflet.markercluster';
import "leaflet/dist/leaflet.css";
import 'react-leaflet-markercluster/dist/styles.min.css';

import "presentation/assets/style/leaflet.css";

import { MapContainer, Polygon, Polyline, TileLayer, useMapEvent } from "react-leaflet";
import { Add, Close, Home, Replay, Settings, Layers } from "@mui/icons-material";

import apiUrl from "core/api";
import useFokontany from "presentation/hooks/useFokontany";
import useConstructionList from "presentation/hooks/useConstructionList";

const MapContext = createContext();
const initialCenter = [-21.83083, 46.932005];

const Map = () => {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));
  const { numcons } = useParams();
  const context = useContext(MapContext);
  const data = context.data;

  const [construction, setConstruction] = useState([]);
  const [isDrawing, setIsDrawing] = useState(false);
  const [center, setCenter] = useState(initialCenter);

  const mapRef = useRef();
  const navigation = useNavigate();

  const handleConstruction = () => {
    if (isDrawing) {
      navigation("/admin/construction/new/" + JSON.stringify(construction));
    }
    setIsDrawing(!isDrawing);
  };

  const handleCancel = () => {
    setIsDrawing(false);
    setConstruction([]);
  };

  const handleReset = () => {
    setConstruction([]);
  };

  const handleMapClick = (e) => {
    if (isDrawing) {
      setConstruction([...construction, e.latlng]);
    }
  };

  const MapEvents = () => {
    useMapEvent({
      click: handleMapClick,
    });

    return null;
  };

  useEffect(() => {
    if (data.length > 0) {
      setCenter(data[0].position);
    }
  }, [data]);

  useEffect(() => {
    const markers = L.markerClusterGroup({
      disableClusteringAtZoom: 18,
    });

    data.forEach((value) => {
      const customMarkerIcon = L.divIcon({
        className: `custom-icon ${numcons === value.numcons ? 'text-danger' : 'text-success'}`,
        html: '<i class="fa fa-home"></i>',
        iconSize: [30, 30],
      });
      const marker = L.marker(value.position, { icon: customMarkerIcon });

      const customPopup = `
        <div class='d-flex'>
          <div>
            <img class='img-marker' src='${value.image ? `${apiUrl}/api/image/${value.image}` : `${apiUrl}/api/image/default.jpg`}' />
          </div>
          <div>
            <span class='ref'>ID: ${value.numcons}</span><br>
            <span class='fw-bold'>${value.proprietaire}</span><br>
            <span class='fw-bold'>${value.surface} m²</span><br>
            <span>Adresse: ${value.adresse || ''} ${value.boriboritany || ''} ${value.fokontany}</span><br>
            <span>Article: ${value.article || 'Inconnu'}</span><br>
            <span>IFPB: ${value.impot}</span><br>
            <a class='btn-link fw-bold' href="/admin/construction/${value.numcons}">Voir plus</a>
          </div>
        </div>
      `;

      marker.bindPopup(customPopup);
      markers.addLayer(marker);
    });

    if (mapRef.current !== null) {
      mapRef.current.addLayer(markers);
    }
  }, [data, numcons]);

  return (
    <Box
      sx={{
        position: 'relative',
        height: 'calc(100vh - 70px)',
        width: '100%',
        overflow: 'hidden'
      }}
    >
      {/* Fokontany Selector - Overlay */}
      <Paper
        elevation={0}
        sx={{
          position: 'absolute',
          top: { xs: 16, sm: 20 },
          right: { xs: 16, sm: 20 },
          zIndex: 1000,
          minWidth: { xs: 200, sm: 280 },
          maxWidth: { xs: 'calc(100% - 32px)', sm: 400 },
          borderRadius: 2,
          border: `1px solid ${alpha('#000', 0.08)}`,
          bgcolor: '#ffffff',
          boxShadow: '0 4px 12px rgba(0, 0, 0, 0.1)'
        }}
      >
        <Box sx={{ p: { xs: 1.5, sm: 2 } }}>
          <FormControl 
            fullWidth
            size={isMobile ? "small" : "medium"}
            sx={{
              '& .MuiOutlinedInput-root': {
                borderRadius: 1.5,
                bgcolor: '#ffffff',
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
                fontSize: { xs: '0.85rem', sm: '0.95rem' },
                '&.Mui-focused': {
                  color: '#1e40af'
                }
              }}
            >
              Fokontany
            </InputLabel>
            <Select
              value={context.selectedFokontany}
              label="Fokontany"
              onChange={(e) => context.setSelectedFokontany(e.target.value)}
              sx={{
                fontSize: { xs: '0.85rem', sm: '0.95rem' }
              }}
            >
              {(context.fokontanyList ?? []).map((fokontany, key) => (
                <MenuItem 
                  key={key} 
                  value={fokontany.id}
                  sx={{
                    fontSize: { xs: '0.85rem', sm: '0.95rem' },
                    '&:hover': {
                      bgcolor: alpha('#1e40af', 0.08)
                    }
                  }}
                >
                  {fokontany.nomfokontany}
                </MenuItem>
              ))}
            </Select>
          </FormControl>

          {/* Stats badge */}
          {data.length > 0 && (
            <Box 
              sx={{ 
                display: 'flex', 
                gap: 1, 
                mt: 1.5,
                flexWrap: 'wrap'
              }}
            >
              <Chip
                icon={<Home sx={{ fontSize: '1rem' }} />}
                label={`${data.length} construction${data.length > 1 ? 's' : ''}`}
                size="small"
                sx={{
                  bgcolor: alpha('#10b981', 0.1),
                  color: '#059669',
                  fontWeight: 600,
                  fontSize: { xs: '0.7rem', sm: '0.75rem' },
                  height: { xs: '24px', sm: '28px' },
                  '& .MuiChip-icon': {
                    color: '#059669'
                  }
                }}
              />
              {isDrawing && (
                <Chip
                  icon={<Layers sx={{ fontSize: '1rem' }} />}
                  label={`${construction.length} point${construction.length > 1 ? 's' : ''}`}
                  size="small"
                  sx={{
                    bgcolor: alpha('#3b82f6', 0.1),
                    color: '#2563eb',
                    fontWeight: 600,
                    fontSize: { xs: '0.7rem', sm: '0.75rem' },
                    height: { xs: '24px', sm: '28px' },
                    '& .MuiChip-icon': {
                      color: '#2563eb'
                    }
                  }}
                />
              )}
            </Box>
          )}
        </Box>
      </Paper>

      {/* Drawing Mode Indicator */}
      {isDrawing && (
        <Paper
          elevation={0}
          sx={{
            position: 'absolute',
            top: { xs: 16, sm: 20 },
            right: { xs: 16, sm: 20 },
            zIndex: 1000,
            px: 2,
            py: 1,
            borderRadius: 2,
            border: `2px solid #3b82f6`,
            bgcolor: alpha('#3b82f6', 0.95),
            color: '#ffffff',
            boxShadow: '0 4px 12px rgba(59, 130, 246, 0.4)',
            animation: 'pulse 2s ease-in-out infinite',
            '@keyframes pulse': {
              '0%, 100%': {
                opacity: 1,
              },
              '50%': {
                opacity: 0.8,
              }
            }
          }}
        >
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <Layers sx={{ fontSize: { xs: '1.1rem', sm: '1.25rem' } }} />
            <Box>
              <Box 
                sx={{ 
                  fontWeight: 700,
                  fontSize: { xs: '0.8rem', sm: '0.85rem' },
                  lineHeight: 1.2
                }}
              >
                Mode tracé actif
              </Box>
              <Box 
                sx={{ 
                  fontSize: { xs: '0.7rem', sm: '0.75rem' },
                  opacity: 0.9
                }}
              >
                Cliquez sur la carte pour tracer
              </Box>
            </Box>
          </Box>
        </Paper>
      )}

      {/* Speed Dial Actions */}
      <SpeedDial
        ariaLabel="Gestion de la carte"
        sx={{
          position: "absolute",
          bottom: { xs: 16, sm: 24 },
          right: { xs: 16, sm: 24 },
          zIndex: 1000,
          '& .MuiSpeedDial-fab': {
            bgcolor: '#1e40af',
            color: '#ffffff',
            width: { xs: 48, sm: 56 },
            height: { xs: 48, sm: 56 },
            boxShadow: '0 4px 12px rgba(30, 64, 175, 0.4)',
            '&:hover': {
              bgcolor: '#1e3a8a',
              boxShadow: '0 6px 16px rgba(30, 64, 175, 0.5)',
            }
          },
          '& .MuiSpeedDialAction-fab': {
            bgcolor: '#ffffff',
            color: '#1e40af',
            boxShadow: '0 2px 8px rgba(0, 0, 0, 0.15)',
            '&:hover': {
              bgcolor: alpha('#1e40af', 0.1),
            }
          }
        }}
        icon={<Settings />}
      >
        {isDrawing && (
          <SpeedDialAction 
            icon={<Close />} 
            onClick={handleCancel} 
            tooltipTitle="Annuler"
            sx={{
              '& .MuiSpeedDialAction-fab': {
                bgcolor: alpha('#ef4444', 0.1),
                color: '#dc2626',
                '&:hover': {
                  bgcolor: alpha('#ef4444', 0.2),
                }
              }
            }}
          />
        )}
        {isDrawing && (
          <SpeedDialAction 
            icon={<Replay />} 
            onClick={handleReset} 
            tooltipTitle="Retracer"
            sx={{
              '& .MuiSpeedDialAction-fab': {
                bgcolor: alpha('#f59e0b', 0.1),
                color: '#d97706',
                '&:hover': {
                  bgcolor: alpha('#f59e0b', 0.2),
                }
              }
            }}
          />
        )}
        <SpeedDialAction 
          icon={isDrawing ? <Add /> : <Home />} 
          onClick={handleConstruction} 
          tooltipTitle={isDrawing ? "Faire l'autodéclaration" : "Tracer la construction"}
          sx={{
            '& .MuiSpeedDialAction-fab': {
              bgcolor: alpha('#10b981', 0.1),
              color: '#059669',
              '&:hover': {
                bgcolor: alpha('#10b981', 0.2),
              }
            }
          }}
        />
      </SpeedDial>

      {/* Map Container */}
      <MapContainer
        center={center}
        zoom={16}
        ref={mapRef}
        style={{ 
          height: '100%', 
          width: '100%',
          zIndex: 1
        }}
      >
        <TileLayer
          url="https://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}"
          maxZoom={20}
          subdomains={['mt1', 'mt2', 'mt3']}
        />

        <MapEvents />
        {isDrawing ? (
          <Polyline
            positions={construction}
            color="#3b82f6"
            weight={3}
            opacity={0.8}
          />
        ) : (
          construction.length > 0 && (
            <Polygon
              positions={construction}
              color="#3b82f6"
              fillColor="#3b82f6"
              fillOpacity={0.3}
              weight={2}
            />
          )
        )}
      </MapContainer>
    </Box>
  );
};

const Carte = () => {
  const { idfoko } = useParams();
  const fokontanyList = useFokontany();
  const { data, selectedFokontany, setSelectedFokontany } = useConstructionList();

  useEffect(() => {
    if (idfoko) {
      setSelectedFokontany(idfoko);
    }
  }, [idfoko, setSelectedFokontany]);

  return (
    <MapContext.Provider value={{
      data,
      selectedFokontany,
      setSelectedFokontany,
      fokontanyList
    }}>
      <Map data={data} />
    </MapContext.Provider>
  );
};

export default Carte;