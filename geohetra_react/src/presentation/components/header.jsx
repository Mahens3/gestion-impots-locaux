// ========== HEADER COMPONENT ==========
import { 
  Box, 
  Button, 
  Stack, 
  Typography,
  alpha,
  useTheme,
  useMediaQuery
} from "@mui/material";
import { useNavigate } from "react-router-dom";
import { Login as LoginIcon } from "@mui/icons-material";
import logo from "presentation/assets/images/logo.png";

const TOP_NAV_HEIGHT = 70;

const Header = () => {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));
  const navigate = useNavigate();

  const toLogin = () => {
    navigate("/login");
  };

  return (
    <Box
      component="header"
      sx={{
        backdropFilter: 'blur(10px)',
        backgroundColor: alpha('#ffffff', 0.95),
        borderBottom: `1px solid ${alpha('#000', 0.08)}`,
        position: 'sticky',
        top: 0,
        width: '100%',
        zIndex: 1100,
        boxShadow: '0 2px 8px rgba(0, 0, 0, 0.05)'
      }}
    >
      <Stack
        alignItems="center"
        direction="row"
        justifyContent="space-between"
        spacing={2}
        sx={{
          minHeight: { xs: 64, sm: TOP_NAV_HEIGHT },
          px: { xs: 2, sm: 3, md: 4 },
          maxWidth: 'xl',
          mx: 'auto'
        }}
      >
        {/* Logo & Brand */}
        <Stack
          alignItems="center"
          direction="row"
          spacing={1.5}
          sx={{
            cursor: 'pointer',
            '&:hover': {
              opacity: 0.8
            },
            transition: 'opacity 0.2s ease'
          }}
          onClick={() => navigate('/')}
        >
          <Box
            sx={{
              width: { xs: 40, sm: 48 },
              height: { xs: 40, sm: 48 },
              borderRadius: 1.5,
              overflow: 'hidden',
              bgcolor: '#ffffff',
              p: 0.5,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              boxShadow: '0 2px 8px rgba(0, 0, 0, 0.1)'
            }}
          >
            <img 
              src={logo} 
              alt="logo Geohetra" 
              style={{ 
                width: '100%', 
                height: '100%', 
                objectFit: 'contain' 
              }}
            />
          </Box>
          
          <Box>
            <Typography
              variant="h6"
              sx={{
                fontWeight: 700,
                color: '#1e293b',
                fontSize: { xs: '1.1rem', sm: '1.25rem' },
                letterSpacing: '-0.3px',
                lineHeight: 1.2
              }}
            >
              Geohetra
            </Typography>
            {!isMobile && (
              <Typography
                variant="caption"
                sx={{
                  color: alpha('#1e293b', 0.6),
                  fontSize: '0.75rem',
                  fontWeight: 500
                }}
              >
                Géomatique et Impôt
              </Typography>
            )}
          </Box>
        </Stack>

        {/* Login Button */}
        <Button
          onClick={toLogin}
          variant="contained"
          startIcon={!isMobile && <LoginIcon />}
          sx={{
            bgcolor: '#1e40af',
            color: '#ffffff',
            fontWeight: 600,
            textTransform: 'none',
            px: { xs: 2.5, sm: 3 },
            py: { xs: 1, sm: 1.25 },
            fontSize: { xs: '0.85rem', sm: '0.95rem' },
            borderRadius: 1.5,
            boxShadow: `0 4px 12px ${alpha('#1e40af', 0.3)}`,
            '&:hover': {
              bgcolor: '#1e3a8a',
              boxShadow: `0 6px 16px ${alpha('#1e40af', 0.4)}`,
              transform: 'translateY(-2px)'
            },
            transition: 'all 0.3s ease'
          }}
        >
          {isMobile ? 'Connexion' : 'Se connecter'}
        </Button>
      </Stack>
    </Box>
  );
};

export default Header;