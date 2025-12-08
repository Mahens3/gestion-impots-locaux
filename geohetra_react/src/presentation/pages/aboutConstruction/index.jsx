import { useCallback, useRef, useState, useEffect } from "react";
import { useNavigate, useParams } from "react-router-dom";
import axios from "data/api/axios";
import { Spinner } from "presentation/components/loader";
import {
  typeconstruction,
  typelogement,
  typeproprietaire,
} from "data/constants/typedata";
import { ToastContainer, toast } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
import * as turf from "turf";
import { formatter } from "presentation/helpers/convertisseur";
import { Table } from "presentation/components/table";
import {
  Box,
  Container,
  Button,
  Typography,
  Grid,
  Paper,
  Chip,
  IconButton,
  alpha,
  useTheme,
  useMediaQuery,
  Card,
  CardMedia,
  Stack
} from "@mui/material";
import {
  AttachMoney,
  Home,
  Receipt,
  Image as ImageIcon,
  Visibility,
  VisibilityOff,
  Print,
  Edit
} from "@mui/icons-material";
import { ModalPayment } from "presentation/components/modal/modal";
import apiUrl from "core/api";
import Formulaire from "./components/formulaire";
import Detail from "presentation/components/details";

const AboutConstruction = () => {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));
  // const isTablet = useMediaQuery(theme.breakpoints.down('md'));

  const { id, geometry } = useParams();
  const [construction, setConstruction] = useState();
  const [fieldConstruction, setFieldConstruction] = useState(typeconstruction);
  const [loading, setLoading] = useState(true);

  const [selectedPayment, setSelectedPayment] = useState();
  const [selectedIndex, setSelectedIndex] = useState();
  const [modal, setModal] = useState(false);
  const [payments, setPayments] = useState([]);
  const [showDetail, setShowDetail] = useState(false);

  const navigation = useNavigate();

  const totalPayement = useCallback(() => {
    let paie = 0;
    payments.forEach((value) => {
      paie += value.montant;
    });
    return paie;
  }, [payments]);

  const actionPayment = (index, data) => {
    return (
      <td style={{ borderBottom: "1px solid #DFDFDF" }}>
        <IconButton
          size="small"
          onClick={() => {
            setSelectedPayment(data);
            setSelectedIndex(index);
            setModal(true);
          }}
          sx={{
            color: '#059669',
            '&:hover': {
              bgcolor: alpha('#059669', 0.1)
            }
          }}
        >
          <Edit fontSize="small" />
        </IconButton>
      </td>
    );
  };

  const handlePayment = (index, value) => {
    let payes = [...payments];
    if (index === null) {
      payes.push(value);
    } else {
      payes[index] = value;
    }
    setPayments(payes);
  };

  const getConstruction = useCallback(
    async (numcons = null) => {
      var response = await axios.get(
        "/api/construction/" + (numcons === null ? id : numcons)
      );
      let data = {
        title: "Fokontany",
        type: "select",
        options: response.data.fokontany.map((value) => ({
          id: value.id,
          value: value.nomfokontany,
        })),
      };
      setFieldConstruction((prevField) => ({
        ...prevField,
        idfoko: data,
      }));
      response.data = response.data.construction;
      if (response.data === null) {
        const calque = Object.keys(typeconstruction).reduce(
          (accumulator, key) => {
            return {
              ...accumulator,
              [key]:
                typeconstruction[key]["type"] === "select"
                  ? typeconstruction[key]["options"][0]
                  : "",
            };
          },
          {}
        );

        let geom = JSON.parse(geometry);
        geom = geom.map((coord) => [coord.lat, coord.lng]);
        geom.push(geom[0]);
        calque["geometry"] = JSON.stringify(geom);
        calque["coord"] = `${geom[0][0]}, ${geom[0][1]}`;
        let polygon = turf.polygon([geom]);
        let surface = turf.area(polygon);
        calque["idfoko"] = data.options[0]["id"];
        calque["surface"] = surface.toFixed(2);
        setConstruction(calque);
      } else {
        if (response.data.proprietaire === null) {
          response.data.proprietaire = {};
          Object.keys(typeproprietaire).forEach((value) => {
            response.data.proprietaire[value] = "";
          });
          response.data.proprietaire["numcons"] = response.data.numcons;
        }

        if (response.data.logements === null) {
          response.data.logements = [];
        }

        let logement = {};
        Object.keys(typelogement).forEach((value) => {
          if (
            typelogement[value].type === "field" ||
            typelogement[value].type === "checkbox"
          ) {
            logement[value] = "";
          } else {
            logement[value] = typelogement[value].options[0];
          }
        });
        logement["numcons"] = response.data.numcons;
        response.data.logements.push(logement);
        response.data.logs.push(logement);
        response.data.logs.map((item) => {
          if (item.confort === null) {
            item.confort = "";
          }
          return item;
        });

        response.data.logements = response.data.logements.filter(
          (logement) => logement !== null
        );
        setPayments(response.data.payments);
        setConstruction(response.data);
      }
      setLoading(false);
    },
    [id, geometry]
  );

  useEffect(() => {
    getConstruction();
  }, [getConstruction]);

  const fileRef = useRef();
  const [file, setFile] = useState();

  const handleImageChange = async (e) => {
    let form = new FormData();
    form.append("image", e.target.files[0]);
    form.append("numcons", construction.numcons);
    await axios.post("/api/addimage", form).then((response) => {
      toast.success("Image changée avec succès");
      setFile(e.target.files[0]);
    });
  };

  return (
    <>
      <ToastContainer position="top-right" autoClose={2000} />
      <Box
        sx={{
          bgcolor: alpha('#f8fafc', 0.8),
          minHeight: 'calc(100vh - 70px)',
          py: { xs: 3, sm: 4 }
        }}
      >
        <Container maxWidth="xl">
          {loading ? (
            <Box display="flex" justifyContent="center" alignItems="center" minHeight="60vh">
              <Spinner />
            </Box>
          ) : (
            <Box>
              {/* Header avec image et info principale */}
              {construction.numcons !== undefined && (
                <Paper
                  elevation={0}
                  sx={{
                    p: { xs: 2.5, sm: 3 },
                    borderRadius: 2,
                    border: `1px solid ${alpha('#000', 0.08)}`,
                    bgcolor: '#ffffff',
                    mb: { xs: 3, sm: 4 }
                  }}
                >
                  <Grid container spacing={{ xs: 2, sm: 3 }}>
                    {/* Image Section */}
                    <Grid item xs={12} md={4}>
                      <Card
                        elevation={0}
                        sx={{
                          borderRadius: 2,
                          border: `1px solid ${alpha('#000', 0.08)}`,
                          position: 'relative',
                          overflow: 'hidden'
                        }}
                      >
                        <CardMedia
                          component="img"
                          height={isMobile ? "200" : "280"}
                          image={
                            file instanceof File
                              ? URL.createObjectURL(file)
                              : `${apiUrl}/api/image/${construction.image}`
                          }
                          alt="Construction"
                          sx={{
                            objectFit: 'cover'
                          }}
                        />
                        <Box
                          sx={{
                            position: 'absolute',
                            bottom: 0,
                            left: 0,
                            right: 0,
                            bgcolor: alpha('#000', 0.7),
                            backdropFilter: 'blur(8px)',
                            p: 1.5,
                            display: 'flex',
                            justifyContent: 'center'
                          }}
                        >
                          <Button
                            variant="contained"
                            startIcon={<ImageIcon />}
                            onClick={() => fileRef.current.click()}
                            size="small"
                            sx={{
                              bgcolor: '#ffffff',
                              color: '#1e293b',
                              fontWeight: 600,
                              textTransform: 'none',
                              '&:hover': {
                                bgcolor: alpha('#ffffff', 0.9)
                              }
                            }}
                          >
                            Changer l'image
                          </Button>
                          <input
                            onChange={handleImageChange}
                            accept="image/*"
                            ref={fileRef}
                            type="file"
                            style={{ display: "none" }}
                          />
                        </Box>
                      </Card>
                    </Grid>

                    {/* Info Section */}
                    <Grid item xs={12} md={8}>
                      <Box>
                        {/* Title & ID */}
                        <Box mb={2}>
                          <Typography
                            variant="h5"
                            sx={{
                              fontWeight: 700,
                              color: '#1e293b',
                              fontSize: { xs: '1.25rem', sm: '1.5rem' },
                              mb: 0.5
                            }}
                          >
                           À propos de la Construction
                          </Typography>
                          <Chip
                            label={`ID: ${construction.numcons}`}
                            size="small"
                            sx={{
                              bgcolor: alpha('#64748b', 0.1),
                              color: '#64748b',
                              fontWeight: 600,
                              fontSize: '0.75rem'
                            }}
                          />
                        </Box>

                        {/* Stats Cards */}
                        <Grid container spacing={2} mb={2}>
                          {/* IFPB */}
                          <Grid item xs={12} sm={6}>
                            <Box
                              sx={{
                                p: 2,
                                borderRadius: 1.5,
                                bgcolor: alpha('#3b82f6', 0.05),
                                border: `1px solid ${alpha('#3b82f6', 0.1)}`
                              }}
                            >
                              <Box display="flex" alignItems="center" gap={1.5}>
                                <Box
                                  sx={{
                                    p: 1,
                                    borderRadius: 1.25,
                                    bgcolor: alpha('#3b82f6', 0.15)
                                  }}
                                >
                                  <AttachMoney sx={{ color: '#2563eb', fontSize: '1.4rem' }} />
                                </Box>
                                <Box>
                                  <Typography
                                    variant="caption"
                                    sx={{
                                      color: alpha('#1e293b', 0.6),
                                      fontSize: '0.75rem',
                                      fontWeight: 500,
                                      display: 'block'
                                    }}
                                  >
                                    IFPB Total
                                  </Typography>
                                  <Typography
                                    variant="h6"
                                    sx={{
                                      color: '#1e293b',
                                      fontWeight: 700,
                                      fontSize: { xs: '1rem', sm: '1.15rem' },
                                      lineHeight: 1.2
                                    }}
                                  >
                                    {construction.impot !== null
                                      ? formatter(construction.impot) + " Ar"
                                      : "N/A"}
                                  </Typography>
                                </Box>
                              </Box>
                            </Box>
                          </Grid>

                          {/* Loyer */}
                          <Grid item xs={12} sm={6}>
                            <Box
                              sx={{
                                p: 2,
                                borderRadius: 1.5,
                                bgcolor: alpha('#10b981', 0.05),
                                border: `1px solid ${alpha('#10b981', 0.1)}`
                              }}
                            >
                              <Box display="flex" alignItems="center" gap={1.5}>
                                <Box
                                  sx={{
                                    p: 1,
                                    borderRadius: 1.25,
                                    bgcolor: alpha('#10b981', 0.15)
                                  }}
                                >
                                  <Home sx={{ color: '#059669', fontSize: '1.4rem' }} />
                                </Box>
                                <Box>
                                  <Typography
                                    variant="caption"
                                    sx={{
                                      color: alpha('#1e293b', 0.6),
                                      fontSize: '0.75rem',
                                      fontWeight: 500,
                                      display: 'block'
                                    }}
                                  >
                                    Loyer mensuel
                                  </Typography>
                                  <Typography
                                    variant="h6"
                                    sx={{
                                      color: '#1e293b',
                                      fontWeight: 700,
                                      fontSize: { xs: '1rem', sm: '1.15rem' },
                                      lineHeight: 1.2
                                    }}
                                  >
                                    {construction.loyer || "N/A"}
                                  </Typography>
                                </Box>
                              </Box>
                            </Box>
                          </Grid>
                        </Grid>

                        {/* Actions */}
                        <Stack
                          direction={{ xs: 'column', sm: 'row' }}
                          spacing={1.5}
                          flexWrap="wrap"
                        >
                          <Button
                            variant="outlined"
                            startIcon={showDetail ? <Visibility /> : <VisibilityOff />}
                            onClick={() => setShowDetail(!showDetail)}
                            sx={{
                              borderColor: alpha('#1e40af', 0.3),
                              color: '#1e40af',
                              fontWeight: 600,
                              textTransform: 'none',
                              '&:hover': {
                                borderColor: '#1e40af',
                                bgcolor: alpha('#1e40af', 0.05)
                              }
                            }}
                          >
                            {showDetail ? "Détail construction" : "Détail calcul"}
                          </Button>

                          <Button
                            variant="contained"
                            startIcon={<Print />}
                            onClick={() => navigation("/avis/" + (construction.numcons || id))}
                            sx={{
                              bgcolor: '#1e40af',
                              color: '#ffffff',
                              fontWeight: 600,
                              textTransform: 'none',
                              boxShadow: `0 4px 12px ${alpha('#1e40af', 0.3)}`,
                              '&:hover': {
                                bgcolor: '#1e3a8a',
                                boxShadow: `0 6px 16px ${alpha('#1e40af', 0.4)}`
                              }
                            }}
                          >
                            Avis d'imposition
                          </Button>
                        </Stack>
                      </Box>
                    </Grid>
                  </Grid>
                </Paper>
              )}

              {/* Content Section */}
              <Grid container spacing={{ xs: 2, sm: 2.5, md: 3 }}>
                {showDetail
                  ? construction !== null && (
                      <Detail data={construction.logements} />
                    )
                  : construction !== null && (
                      <>
                        {/* Construction Form */}
                        <Grid item xs={12}>
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

                        {/* Propriétaire Form */}
                        {construction.numcons !== undefined && (
                          <Grid item xs={12}>
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
                        )}

                        {/* Logements Forms */}
                        {construction.numcons !== undefined &&
                          construction.logs.map((value, index) => (
                            <Grid item key={value.id ?? index} xs={12}>
                              <Formulaire
                                id="numlog"
                                icon="fa fa-folder"
                                data={value}
                                col={3}
                                index={index}
                                parameter={typelogement}
                                refresh={getConstruction}
                                title="Logement"
                                url="/logement"
                              />
                            </Grid>
                          ))}

                        {/* Paiements Section */}
                        {construction.numcons !== undefined && (
                          <Grid item xs={12}>
                            <Paper
                              elevation={0}
                              sx={{
                                p: { xs: 2.5, sm: 3 },
                                borderRadius: 2,
                                border: `1px solid ${alpha('#000', 0.08)}`,
                                bgcolor: '#ffffff'
                              }}
                            >
                              <Box
                                display="flex"
                                alignItems="center"
                                gap={1.5}
                                mb={2.5}
                              >
                                <Box
                                  sx={{
                                    p: 1,
                                    borderRadius: 1.25,
                                    bgcolor: alpha('#059669', 0.1)
                                  }}
                                >
                                  <Receipt sx={{ color: '#059669', fontSize: '1.5rem' }} />
                                </Box>
                                <Typography
                                  variant="h6"
                                  sx={{
                                    fontWeight: 700,
                                    color: '#1e293b',
                                    fontSize: { xs: '1rem', sm: '1.1rem' }
                                  }}
                                >
                                  Paiements effectués
                                </Typography>
                              </Box>

                              {modal && (
                                <ModalPayment
                                  resteApaye={
                                    parseInt(construction.impot) - totalPayement()
                                  }
                                  state={selectedPayment}
                                  setState={handlePayment}
                                  index={selectedIndex}
                                  numcons={construction.numcons}
                                  closeModal={() => setModal(!modal)}
                                />
                              )}

                              <Table
                                add={() => setModal(true)}
                                colaction={actionPayment}
                                withIndex={true}
                                keys={[
                                  "quittance",
                                  "montant",
                                  "datePayment",
                                  "timePayment",
                                ]}
                                title={[
                                  "Quittance",
                                  "Montant",
                                  "Date paiement",
                                  "Heure paiement",
                                ]}
                                rows={payments}
                              />
                            </Paper>
                          </Grid>
                        )}
                      </>
                    )}
              </Grid>
            </Box>
          )}
        </Container>
      </Box>
    </>
  );
};

export default AboutConstruction;