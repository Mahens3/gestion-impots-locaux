import { Box, Button, Stack, Typography } from "@mui/material";
import { Link, useNavigate } from "react-router-dom";
import { alpha } from '@mui/material/styles';

const TOP_NAV_HEIGHT = 64;

const Header = () => {
    const navigate = useNavigate()

    const toLogin = () => {
        navigate("/login")
    }

    return (
        <>
            <Box
                component="header"
                sx={{
                    backdropFilter: 'blur(6px)',
                    backgroundColor: alpha('#000', 0.1),
                    position: 'sticky',
                    top: 0,
                    width: "100%",
                    zIndex: 1100,
                }}
            >
                <Stack
                    alignItems="center"
                    direction="row"
                    justifyContent="space-between"
                    spacing={2}
                    sx={{
                        minHeight: TOP_NAV_HEIGHT,
                        padding: '0 16px',
                    }}
                >
                    <Stack
                        alignItems="center"
                        direction="row"
                        justifyContent="space-between"
                    >
                        <Link to="/" style={{ display: 'flex', height: 50, width: 50, marginRight: 5 }}>
                            <img src="/images/logo.png" />
                        </Link>
                        <Box>
                            <Typography color="inherit" variant="h5">
                                Geohetra
                            </Typography>
                        </Box>
                    </Stack>
                    <Box>
                        <Button
                            onClick={toLogin}
                            sx={{ textTransform: "none" }}
                            variant="contained"
                            size="medium"
                            color="success" >
                            Se connecter
                        </Button>
                    </Box>
                </Stack>
            </Box>
        </>
    )
}

export default Header