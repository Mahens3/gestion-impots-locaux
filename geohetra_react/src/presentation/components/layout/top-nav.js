import { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import MenuIcon from '@mui/icons-material/Menu';
import {
  Box,
  IconButton,
  Menu,
  MenuItem,
  Stack,
  Typography,
  Avatar,
  Divider,
  // Badge,
  Chip,
  useMediaQuery,
  useTheme
} from '@mui/material';
import { alpha } from '@mui/material/styles';
import { useNavigate, useLocation } from 'react-router-dom';
import { 
  AccountBox, 
  History, 
  Logout, 
  // Notifications,
  KeyboardArrowDown
} from '@mui/icons-material';

const SIDE_NAV_WIDTH = 280;
const TOP_NAV_HEIGHT = 70;
const TOP_NAV_HEIGHT_MOBILE = 64;

const TopNav = (props) => {
  const navigate = useNavigate();
  const location = useLocation();
  const theme = useTheme();
  const [anchorEl, setAnchorEl] = useState(null);
  const [lgUp, setLgUp] = useState(window.matchMedia('(min-width: 1280px)').matches);
  
  // Media queries pour responsive
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));
  const isTablet = useMediaQuery(theme.breakpoints.down('md'));

  // Simuler des données utilisateur (à remplacer par vos vraies données)
  const userData = {
    name: "Admin Geohetra",
    email: "admin@geohetra.mg",
    role: "Administrateur",
    initials: "AG"
  };

  useEffect(() => {
    const handleResize = () => {
      setLgUp(window.matchMedia('(min-width: 1280px)').matches);
    };

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const handleClick = (event) => {
    setAnchorEl(event.currentTarget);
  };

  const handleClose = () => {
    setAnchorEl(null);
  };

  const handleLogout = () => {
    handleClose();
    localStorage.removeItem("_token");
    localStorage.removeItem("search");
    localStorage.removeItem("page");
    navigate("/");
  };

  // Obtenir le titre de la page actuelle
  const getPageTitle = () => {
    const path = location.pathname;
    if (path.includes('dashboard')) return 'Tableau de bord';
    if (path.includes('construction') && !path.includes('suivi')) return 'Construction';
    if (path.includes('avis')) return "Avis d'imposition";
    if (path.includes('suivi')) return 'Suivi';
    if (path.includes('map')) return 'Carte';
    return 'Geohetra';
  };

  const getPageSubtitle = () => {
    if (isMobile) return null;
    return 'Gestion des impôts fonciers - CU Ambalavao';
  };

  const { onNavOpen } = props;

  return (
    <Box
      component="header"
      sx={{
        backdropFilter: 'blur(10px)',
        backgroundColor: alpha('#ffffff', 0.95),
        borderBottom: `1px solid ${alpha('#000', 0.08)}`,
        position: 'sticky',
        left: lgUp ? `${SIDE_NAV_WIDTH}px` : 0,
        top: 0,
        width: lgUp ? `calc(100% - ${SIDE_NAV_WIDTH}px)` : '100%',
        zIndex: 1100,
        boxShadow: '0 2px 8px rgba(0, 0, 0, 0.05)',
        transition: 'all 0.3s ease',
      }}
    >
      <Stack
        alignItems="center"
        direction="row"
        justifyContent="space-between"
        spacing={{ xs: 1, sm: 2 }}
        sx={{
          minHeight: isMobile ? TOP_NAV_HEIGHT_MOBILE : TOP_NAV_HEIGHT,
          px: { xs: 1.5, sm: 2, md: 3 },
        }}
      >
        {/* Left Section */}
        <Stack
          alignItems="center"
          direction="row"
          spacing={{ xs: 1, sm: 1.5 }}
          sx={{ flex: 1, minWidth: 0 }}
        >
          {!lgUp && (
            <IconButton 
              onClick={onNavOpen}
              size={isMobile ? "small" : "medium"}
              sx={{
                color: '#1e40af',
                '&:hover': {
                  backgroundColor: alpha('#1e40af', 0.1),
                }
              }}
            >
              <MenuIcon fontSize={isMobile ? "small" : "medium"} />
            </IconButton>
          )}
          
          <Box sx={{ minWidth: 0, flex: 1 }}>
            <Typography 
              variant={isMobile ? "h6" : "h5"}
              sx={{ 
                fontWeight: 700,
                color: '#1e293b',
                fontSize: { xs: '1.1rem', sm: '1.25rem', md: '1.4rem' },
                letterSpacing: '-0.5px',
                whiteSpace: 'nowrap',
                overflow: 'hidden',
                textOverflow: 'ellipsis'
              }}
            >
              {getPageTitle()}
            </Typography>
            {!isMobile && getPageSubtitle() && (
              <Typography 
                variant="caption" 
                sx={{ 
                  color: '#64748b',
                  fontSize: { xs: '0.7rem', md: '0.75rem' },
                  display: { xs: 'none', sm: 'block' }
                }}
              >
                {getPageSubtitle()}
              </Typography>
            )}
          </Box>
        </Stack>

        {/* Right Section */}
        <Stack
          alignItems="center"
          direction="row"
          spacing={{ xs: 0.5, sm: 1, md: 2 }}
        >
          {/* Notifications */}
          {/* <IconButton
            size={isMobile ? "small" : "medium"}
            sx={{
              color: '#64748b',
              '&:hover': {
                backgroundColor: alpha('#1e40af', 0.1),
                color: '#1e40af'
              }
            }}
          >
            <Badge 
              badgeContent={3} 
              color="error"
              sx={{
                '& .MuiBadge-badge': {
                  fontSize: { xs: '0.6rem', sm: '0.65rem' },
                  height: { xs: '16px', sm: '18px' },
                  minWidth: { xs: '16px', sm: '18px' },
                  fontWeight: 600
                }
              }}
            >
              <Notifications fontSize={isMobile ? "small" : "medium"} />
            </Badge>
          </IconButton> */}

          {/* {!isMobile && (
            <Divider 
              orientation="vertical" 
              flexItem 
              sx={{ 
                mx: { sm: 0.5, md: 1 }, 
                borderColor: alpha('#000', 0.1),
                display: { xs: 'none', sm: 'block' }
              }} 
            />
          )} */}

          {/* User Menu */}
          <Box
            onClick={handleClick}
            sx={{
              display: 'flex',
              alignItems: 'center',
              gap: { xs: 0.5, sm: 1, md: 1.5 },
              cursor: 'pointer',
              px: { xs: 0.5, sm: 1, md: 1.5 },
              py: { xs: 0.5, sm: 0.75 },
              borderRadius: 2,
              transition: 'all 0.2s ease',
              '&:hover': {
                backgroundColor: alpha('#1e40af', 0.08),
              }
            }}
          >
            <Avatar
              sx={{
                width: { xs: 32, sm: 36, md: 38 },
                height: { xs: 32, sm: 36, md: 38 },
                bgcolor: '#1e40af',
                fontWeight: 600,
                fontSize: { xs: '0.8rem', sm: '0.9rem', md: '0.95rem' },
                border: '2px solid #ffffff',
                boxShadow: '0 2px 8px rgba(30, 64, 175, 0.25)'
              }}
            >
              {userData.initials}
            </Avatar>
            
            {/* Info utilisateur - Hidden on mobile and small tablets */}
            {!isTablet && (
              <Box sx={{ 
                display: { xs: 'none', md: 'flex' },
                flexDirection: 'column', 
                alignItems: 'flex-start',
                maxWidth: '150px'
              }}>
                <Typography 
                  variant="body2" 
                  sx={{ 
                    fontWeight: 600,
                    color: '#1e293b',
                    lineHeight: 1.2,
                    fontSize: '0.875rem',
                    whiteSpace: 'nowrap',
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                    width: '100%'
                  }}
                >
                  {userData.name}
                </Typography>
                <Chip
                  label={userData.role}
                  size="small"
                  sx={{
                    height: '18px',
                    fontSize: '0.65rem',
                    fontWeight: 600,
                    backgroundColor: alpha('#10b981', 0.1),
                    color: '#059669',
                    mt: 0.25,
                    '& .MuiChip-label': {
                      px: 1
                    }
                  }}
                />
              </Box>
            )}
            
            <KeyboardArrowDown 
              sx={{ 
                color: '#94a3b8',
                fontSize: { xs: '1rem', sm: '1.15rem', md: '1.25rem' },
                transition: 'transform 0.2s ease',
                transform: Boolean(anchorEl) ? 'rotate(180deg)' : 'rotate(0deg)'
              }} 
            />
          </Box>

          {/* Dropdown Menu - Responsive */}
          <Menu
            anchorEl={anchorEl}
            open={Boolean(anchorEl)}
            onClose={handleClose}
            anchorOrigin={{
              vertical: 'bottom',
              horizontal: 'right',
            }}
            transformOrigin={{
              vertical: 'top',
              horizontal: 'right',
            }}
            PaperProps={{
              sx: {
                mt: 1.5,
                minWidth: { xs: 200, sm: 240 },
                maxWidth: { xs: '90vw', sm: 300 },
                borderRadius: 2,
                boxShadow: '0 8px 24px rgba(0, 0, 0, 0.12)',
                border: `1px solid ${alpha('#000', 0.08)}`,
              }
            }}
          >
            {/* User Info in Menu */}
            <Box sx={{ 
              px: { xs: 1.5, sm: 2 }, 
              py: { xs: 1.25, sm: 1.5 }, 
              borderBottom: `1px solid ${alpha('#000', 0.08)}` 
            }}>
              <Typography 
                variant="subtitle2" 
                sx={{ 
                  fontWeight: 600, 
                  color: '#1e293b',
                  fontSize: { xs: '0.85rem', sm: '0.9rem' },
                  whiteSpace: 'nowrap',
                  overflow: 'hidden',
                  textOverflow: 'ellipsis'
                }}
              >
                {userData.name}
              </Typography>
              <Typography 
                variant="caption" 
                sx={{ 
                  color: '#64748b',
                  fontSize: { xs: '0.7rem', sm: '0.75rem' },
                  whiteSpace: 'nowrap',
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                  display: 'block'
                }}
              >
                {userData.email}
              </Typography>
            </Box>

            <MenuItem 
              onClick={() => {
                handleClose();
                // navigate('/admin/history');
              }}
              sx={{
                py: { xs: 1.25, sm: 1.5 },
                px: { xs: 1.5, sm: 2 },
                '&:hover': {
                  backgroundColor: alpha('#1e40af', 0.08),
                }
              }}
            >
              <History sx={{ 
                mr: { xs: 1.25, sm: 1.5 }, 
                color: '#64748b', 
                fontSize: { xs: '1.15rem', sm: '1.25rem' } 
              }} />
              <Typography variant="body2" sx={{ fontWeight: 500, fontSize: { xs: '0.85rem', sm: '0.9rem' } }}>
                Historique
              </Typography>
            </MenuItem>

            <MenuItem 
              onClick={() => {
                handleClose();
                // navigate('/admin/profile');
              }}
              sx={{
                py: { xs: 1.25, sm: 1.5 },
                px: { xs: 1.5, sm: 2 },
                '&:hover': {
                  backgroundColor: alpha('#1e40af', 0.08),
                }
              }}
            >
              <AccountBox sx={{ 
                mr: { xs: 1.25, sm: 1.5 }, 
                color: '#64748b', 
                fontSize: { xs: '1.15rem', sm: '1.25rem' } 
              }} />
              <Typography variant="body2" sx={{ fontWeight: 500, fontSize: { xs: '0.85rem', sm: '0.9rem' } }}>
                Mon profil
              </Typography>
            </MenuItem>

            <Divider sx={{ my: 1 }} />

            <MenuItem 
              onClick={handleLogout}
              sx={{
                py: { xs: 1.25, sm: 1.5 },
                px: { xs: 1.5, sm: 2 },
                color: '#dc2626',
                '&:hover': {
                  backgroundColor: alpha('#dc2626', 0.08),
                }
              }}
            >
              <Logout sx={{ 
                mr: { xs: 1.25, sm: 1.5 }, 
                fontSize: { xs: '1.15rem', sm: '1.25rem' } 
              }} />
              <Typography variant="body2" sx={{ fontWeight: 600, fontSize: { xs: '0.85rem', sm: '0.9rem' } }}>
                Se déconnecter
              </Typography>
            </MenuItem>
          </Menu>
        </Stack>
      </Stack>
    </Box>
  );
};

TopNav.propTypes = {
  onNavOpen: PropTypes.func,
};

export default TopNav;