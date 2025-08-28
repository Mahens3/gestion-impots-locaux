import PropTypes from 'prop-types';
import { Box, Typography, Unstable_Grid2 as Grid } from '@mui/material';

import img from "presentation/assets/images/2.jpg"


export const Layout = (props) => {
    const { children } = props;

    return (
        <Box
            component="main"
            sx={{
                display: 'flex',
                flex: '1 1 auto'
            }}
        >
            <Grid
                container
                sx={{ flex: '1 1 auto' }}
            >
                <Grid
                    xs={12}
                    lg={6}
                    sx={{
                        backgroundColor: 'background.paper',
                        display: 'flex',
                        flexDirection: 'column',
                        position: 'relative'
                    }}
                >
                    <Box
                        component="header"
                        sx={{
                            left: 0,
                            p: 3,
                            position: 'fixed',
                            top: 0,
                            width: '100%'
                        }}
                    >
                        <Box
                            href="/"
                            sx={{
                                display: 'inline-flex',
                                height: 32,
                                width: 32
                            }}
                        >
                            <img src='/images/logo.png' />
                        </Box>
                    </Box>
                    {children}
                </Grid>
                <Grid
                    xs={12}
                    lg={6}
                    sx={{
                        alignItems: 'center',
                        backgroundImage : `url(${img})` ,
                        
                        backgroundSize : "cover",
                        color: 'white',
                        display: 'flex',
                        justifyContent: 'center',
                        height : "100vh"
                    }}
                >
                    <Box sx={{ p: 3 }}>
                        <Typography
                            align="center"
                            color="inherit"
                            sx={{
                                fontSize: '24px',
                                lineHeight: '32px',
                                mb: 1
                            }}
                            variant="h1"
                        >
                            Bienvenue au{' '}
                            <Box
                                component="a"
                                sx={{ color: '#15B79E' }}
                                target="_blank"
                            >
                                Geohetra
                            </Box>
                        </Typography>
                        <Typography
                            align="center"
                            sx={{ mb: 3 }}
                            variant="subtitle1"
                        >
                            Optimisation du processus de collecte et gestion des données sur l'impot foncier des propriétés bâtis.
                        </Typography>
                    </Box>
                </Grid>
            </Grid>
        </Box>
    );
};

Layout.prototypes = {
    children: PropTypes.node
};