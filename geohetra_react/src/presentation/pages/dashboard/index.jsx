import { useState, useEffect } from "react";
import axios from "data/api/axios";
import {
  Box,
  Container,
  Grid,
  Paper,
  Typography,
  alpha,
} from "@mui/material";
import { Home, Payments, AttachMoney } from "@mui/icons-material";
import { BarChart, SplineChart } from "presentation/components/layout/chart";
import { formatter } from "presentation/helpers/convertisseur";
import { Spinner } from "presentation/components/loader";

const Dashboard = () => {
  const [data, setData] = useState({
    ready: false,
    dataBar: [],
    dataSpline: [],
    construction: 0,
    ifpb: 0,
    paiement: 0,
  });

  const fetch = async () => {
    let response = await axios.get("api/dashboard");
    response.data["ready"] = true;
    setData(response.data);
  };

  useEffect(() => {
    fetch();
  }, []);

  // KPI Card simple et moderne
  const KPICard = ({ title, value, icon: Icon, color, bgColor }) => (
    <Paper
      elevation={0}
      sx={{
        p: { xs: 2, sm: 2.5 },
        borderRadius: 2,
        border: `1px solid ${alpha("#000", 0.08)}`,
        bgcolor: "#ffffff",
        height: "100%",
        transition: "all 0.3s ease",
        "&:hover": {
          borderColor: alpha(color, 0.3),
          boxShadow: `0 4px 12px ${alpha(color, 0.08)}`,
          transform: "translateY(-2px)",
        },
      }}
    >
      <Box display="flex" alignItems="center" gap={{ xs: 1.5, sm: 2 }}>
        <Box
          sx={{
            p: { xs: 1.25, sm: 1.5 },
            borderRadius: 1.5,
            bgcolor: alpha(bgColor, 0.1),
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            flexShrink: 0,
          }}
        >
          <Icon
            sx={{
              color: color,
              fontSize: { xs: "1.5rem", sm: "1.75rem" },
            }}
          />
        </Box>

        <Box flex={1} minWidth={0}>
          <Typography
            variant="body2"
            sx={{
              color: alpha("#1e293b", 0.6),
              fontSize: { xs: "0.75rem", sm: "0.8rem" },
              fontWeight: 500,
              mb: 0.25,
              letterSpacing: "0.3px",
            }}
          >
            {title}
          </Typography>

          <Typography
            variant="h6"
            sx={{
              color: "#1e293b",
              fontWeight: 700,
              fontSize: { xs: "1.15rem", sm: "1.3rem", md: "1.4rem" },
              letterSpacing: "-0.3px",
              lineHeight: 1.2,
              whiteSpace: "nowrap",
              overflow: "hidden",
              textOverflow: "ellipsis",
            }}
          >
            {value}
          </Typography>
        </Box>
      </Box>
    </Paper>
  );

  // Item pour pourcentage payé - cohérent avec le sidebar
  const PercentageItem = ({ item }) => {
    const percentage = ((item.z * 100) / item.y).toFixed(2);
    const isPaid = item.y - item.z <= 0;
    const remaining = formatter(item.y - item.z);

    return (
      <Box
        sx={{
          py: { xs: 1.25, sm: 1.5 },
          px: { xs: 1.5, sm: 2 },
          mb: 1,
          borderRadius: 1.5,
          bgcolor: "transparent",
          transition: "all 0.2s ease",
          cursor: "pointer",
          "&:hover": {
            bgcolor: alpha("#1e40af", 0.06),
            transform: "translateX(4px)",
          },
        }}
      >
        <Box
          display="flex"
          justifyContent="space-between"
          alignItems="center"
          mb={0.5}
        >
          <Typography
            variant="body2"
            noWrap
            sx={{
              fontWeight: 600,
              color: "#1e293b",
              fontSize: { xs: "0.8rem", sm: "0.85rem" },
              maxWidth: "65%",
            }}
          >
            {item.fkt}
          </Typography>
          <Typography
            variant="body2"
            sx={{
              fontWeight: 700,
              color: isPaid ? "#059669" : "#2563eb",
              fontSize: { xs: "0.8rem", sm: "0.85rem" },
            }}
          >
            {percentage}%
          </Typography>
        </Box>
        <Typography
          variant="caption"
          sx={{
            color: alpha("#1e293b", 0.6),
            fontSize: { xs: "0.7rem", sm: "0.75rem" },
            display: "block",
          }}
        >
          Reste:{" "}
          <Box
            component="span"
            sx={{ fontWeight: 600, color: alpha("#1e293b", 0.7) }}
          >
            {remaining} Ar
          </Box>
        </Typography>
      </Box>
    );
  };

  return (
    <Box
      sx={{
        bgcolor: alpha("#f8fafc", 0.8),
        minHeight: "calc(100vh - 70px)",
        py: { xs: 3, sm: 4 },
      }}
    >
      <Container maxWidth="xl">
        {data.ready ? (
          <>
            {/* KPI Cards - Style simple */}
            <Grid
              container
              spacing={{ xs: 2, sm: 2.5, md: 3 }}
              mb={{ xs: 3, sm: 3.5, md: 4 }}
            >
              <Grid item xs={12} sm={6} md={4}>
                <KPICard
                  title="Total Construction"
                  value={`${formatter(data.construction)} toits`}
                  icon={Home}
                  color="#059669"
                  bgColor="#10b981"
                />
              </Grid>
              <Grid item xs={12} sm={6} md={4}>
                <KPICard
                  title="Total IFPB"
                  value={`${formatter(data.ifpb)} Ar`}
                  icon={AttachMoney}
                  color="#2563eb"
                  bgColor="#3b82f6"
                />
              </Grid>
              <Grid item xs={12} sm={12} md={4}>
                <KPICard
                  title="Paiement Effectué"
                  value={`${formatter(data.paiement)} Ar`}
                  icon={Payments}
                  color="#d97706"
                  bgColor="#f59e0b"
                />
              </Grid>
            </Grid>

            {/* Charts Section */}
            <Grid container spacing={{ xs: 2, sm: 2.5, md: 3 }}>
              {/* Graphiques */}
              <Grid item xs={12} lg={8}>
                {/* Bar Chart */}
                <Paper
                  elevation={0}
                  sx={{
                    p: { xs: 2.5, sm: 3 },
                    borderRadius: 2,
                    border: `1px solid ${alpha("#000", 0.08)}`,
                    mb: { xs: 2, sm: 2.5, md: 3 },
                    bgcolor: "#ffffff",
                  }}
                >
                  <Box mb={{ xs: 2.5, sm: 3 }}>
                    <Typography
                      variant="h6"
                      sx={{
                        fontWeight: 700,
                        color: "#1e293b",
                        fontSize: { xs: "0.95rem", sm: "1rem", md: "1.1rem" },
                        lineHeight: 1.3,
                      }}
                    >
                      {/* Diagramme en barre de l'IFPB et leur paiement respectif */}
                      IFPB et paiements par quartier
                    </Typography>
                  </Box>
                  <Box
                    sx={{
                      height: { xs: 280, sm: 340, md: 380 },
                      overflow: "hidden",
                    }}
                  >
                    <BarChart
                      data={data.dataBar}
                      title={["IFPB", "Paiement"]}
                    />
                  </Box>
                </Paper>

                {/* Spline Chart */}
                <Paper
                  elevation={0}
                  sx={{
                    p: { xs: 2.5, sm: 3 },
                    borderRadius: 2,
                    border: `1px solid ${alpha("#000", 0.08)}`,
                    bgcolor: "#ffffff",
                  }}
                >
                  <Box mb={{ xs: 2.5, sm: 3 }}>
                    <Typography
                      variant="h6"
                      sx={{
                        fontWeight: 700,
                        color: "#1e293b",
                        fontSize: { xs: "0.95rem", sm: "1rem", md: "1.1rem" },
                        lineHeight: 1.3,
                      }}
                    >
                      Courbe du paiement de l'IFPB
                    </Typography>
                  </Box>
                  <Box
                    sx={{
                      height: { xs: 280, sm: 340, md: 380 },
                      overflow: "hidden",
                    }}
                  >
                    <SplineChart data={data.dataSpline} />
                  </Box>
                </Paper>
              </Grid>

              {/* Sidebar - Pourcentages */}
              <Grid item xs={12} lg={4}>
                <Paper
                  elevation={0}
                  sx={{
                    p: { xs: 2.5, sm: 3 },
                    borderRadius: 2,
                    border: `1px solid ${alpha("#000", 0.08)}`,
                    bgcolor: "#ffffff",
                    height: { lg: "100%" },
                    display: "flex",
                    flexDirection: "column",
                  }}
                >
                  <Box mb={{ xs: 2.5, sm: 3 }} flexShrink={0}>
                    <Typography
                      variant="h6"
                      sx={{
                        fontWeight: 700,
                        color: "#1e293b",
                        fontSize: { xs: "0.95rem", sm: "1rem", md: "1.1rem" },
                        lineHeight: 1.3,
                      }}
                    >
                      Pourcentage payé et reste à payé
                    </Typography>
                  </Box>
                  <Box
                    sx={{
                      flex: 1,
                      maxHeight: { xs: 450, sm: 500, lg: "none" },
                      overflowY: "auto",
                      pr: 0.5,

                      // Firefox
                      scrollbarWidth: "thin",
                      scrollbarColor: `${alpha("#1e40af", 0.25)} transparent`,

                      // Chrome / Edge / Safari
                      "&::-webkit-scrollbar": {
                        width: "6px",
                      },
                      "&::-webkit-scrollbar-track": {
                        background: alpha("#1e40af", 0.05),
                        borderRadius: "3px",
                      },
                      "&::-webkit-scrollbar-thumb": {
                        background: alpha("#1e40af", 0.25),
                        borderRadius: "3px",
                      },
                      "&::-webkit-scrollbar-thumb:hover": {
                        background: alpha("#1e40af", 0.4),
                      },
                    }}
                  >
                    {data.dataBar.map((item, index) => (
                      <PercentageItem key={index} item={item} />
                    ))}
                  </Box>
                </Paper>
              </Grid>
            </Grid>
          </>
        ) : (
          <Box
            display="flex"
            justifyContent="center"
            alignItems="center"
            minHeight="60vh"
          >
            <Spinner />
          </Box>
        )}
      </Container>
    </Box>
  );
};

export default Dashboard;
