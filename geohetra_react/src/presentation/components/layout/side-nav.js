import { useState, useEffect } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import logo from "presentation/assets/images/logo.png";
import PropTypes from 'prop-types';
import {
  Box,
  Button,
  Divider,
  Drawer,
  Typography,
  alpha
} from '@mui/material';
import { items } from './config';
import { SideNavItem } from './side-nav-item';
import MapIcon from '@mui/icons-material/Map';

const SideNav = (props) => {
  const { open, onClose } = props;
  const navigate = useNavigate();
  const location = useLocation();
  const [lgUp, setLgUp] = useState(window.matchMedia('(min-width: 1200px)').matches);

  useEffect(() => {
    const handleResize = () => {
      setLgUp(window.matchMedia('(min-width: 1200px)').matches);
    };

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const content = (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        height: '100%',
        background: 'linear-gradient(180deg, #1e40af 0%, #1e3a8a 100%)',
        overflowY: 'auto',
        '&::-webkit-scrollbar': {
          width: '6px',
        },
        '&::-webkit-scrollbar-track': {
          background: 'transparent',
        },
        '&::-webkit-scrollbar-thumb': {
          background: alpha('#ffffff', 0.2),
          borderRadius: '3px',
          '&:hover': {
            background: alpha('#ffffff', 0.3),
          }
        }
      }}
    >
      {/* Header avec logo - Responsive */}
      <Box sx={{ p: { xs: 2, sm: 2.5, md: 3 } }}>
        <Box
          sx={{
            alignItems: 'center',
            backgroundColor: alpha('#ffffff', 0.1),
            backdropFilter: 'blur(10px)',
            borderRadius: 2,
            cursor: 'pointer',
            display: 'flex',
            justifyContent: 'flex-start',
            p: { xs: 1.5, sm: 2 },
            transition: 'all 0.3s ease',
            '&:hover': {
              backgroundColor: alpha('#ffffff', 0.15),
              transform: 'translateY(-2px)',
              boxShadow: '0 4px 12px rgba(0, 0, 0, 0.15)',
            }
          }}
        >
          <Link 
            to="/" 
            style={{ 
              display: 'flex', 
              height: 44, 
              width: 44, 
              marginRight: 10,
              borderRadius: '8px',
              overflow: 'hidden',
              backgroundColor: '#ffffff',
              padding: '4px',
              flexShrink: 0
            }}
          >
            <img 
              src={logo} 
              alt='logo Geohetra' 
              style={{ width: '100%', height: '100%', objectFit: 'contain' }}
            />
          </Link>
          <Box sx={{ minWidth: 0, flex: 1 }}>
            <Typography 
              color="inherit" 
              variant="h6"
              sx={{ 
                fontWeight: 700,
                fontSize: { xs: '1rem', sm: '1.05rem', md: '1.1rem' },
                letterSpacing: '0.5px',
                whiteSpace: 'nowrap',
                overflow: 'hidden',
                textOverflow: 'ellipsis'
              }}
            >
              Geohetra
            </Typography>
            <Typography 
              sx={{ 
                fontSize: { xs: '0.7rem', sm: '0.72rem', md: '0.75rem' },
                color: alpha('#ffffff', 0.8),
                fontWeight: 500,
                whiteSpace: 'nowrap',
                overflow: 'hidden',
                textOverflow: 'ellipsis'
              }}
            >
              Géomatique et Impôt
            </Typography>
          </Box>
        </Box>
      </Box>

      <Divider sx={{ borderColor: alpha('#ffffff', 0.15), mx: 2 }} />

      {/* Navigation - Responsive */}
      <Box
        component="nav"
        sx={{
          flex: 1,
          px: { xs: 1.5, sm: 2 },
          py: { xs: 1.5, sm: 2 },
          overflowY: 'auto',
          '&::-webkit-scrollbar': {
            width: '6px',
          },
          '&::-webkit-scrollbar-track': {
            background: 'transparent',
          },
          '&::-webkit-scrollbar-thumb': {
            background: alpha('#ffffff', 0.2),
            borderRadius: '3px',
            '&:hover': {
              background: alpha('#ffffff', 0.3),
            }
          }
        }}
      >
        <Typography
          variant="overline"
          sx={{
            color: alpha('#ffffff', 0.6),
            fontSize: { xs: '0.65rem', sm: '0.7rem' },
            fontWeight: 700,
            letterSpacing: '1.2px',
            px: { xs: 1.5, sm: 2 },
            mb: 1,
            display: 'block'
          }}
        >
          MENU PRINCIPAL
        </Typography>
        {items.map((item) => {
          const active = item.path ? (location.pathname === item.path) : false;
          return (
            <SideNavItem
              active={active}
              disabled={item.disabled}
              external={item.external}
              icon={item.icon}
              key={item.title}
              path={item.path}
              title={item.title}
            />
          );
        })}
      </Box>

      <Divider sx={{ borderColor: alpha('#ffffff', 0.15), mx: 2 }} />

      {/* Call to action - Carte - Responsive */}
      <Box
        sx={{
          p: { xs: 2, sm: 2.5, md: 3 },
          mt: 'auto'
        }}
      >
        <Box
          sx={{
            backgroundColor: alpha('#ffffff', 0.08),
            borderRadius: 2,
            p: { xs: 2, sm: 2.5 },
            border: `1px solid ${alpha('#ffffff', 0.12)}`
          }}
        >
          <Box sx={{ display: 'flex', alignItems: 'center', mb: { xs: 1.25, sm: 1.5 } }}>
            <MapIcon sx={{ color: '#60a5fa', mr: 1, fontSize: { xs: 22, sm: 24 } }} />
            <Typography 
              color="#ffffff" 
              variant="subtitle2"
              sx={{ 
                fontWeight: 600, 
                fontSize: { xs: '0.85rem', sm: '0.9rem' }
              }}
            >
              Visualisation
            </Typography>
          </Box>
          <Typography 
            sx={{ 
              color: alpha('#ffffff', 0.8),
              fontSize: { xs: '0.75rem', sm: '0.8rem' },
              mb: { xs: 1.5, sm: 2 },
              lineHeight: 1.5,
              display: { xs: 'none', sm: 'block' }
            }}
          >
            Explorez les constructions sur une carte interactive
          </Typography>
          <Button
            fullWidth
            variant="contained"
            startIcon={<MapIcon sx={{ fontSize: { xs: '1rem', sm: '1.2rem' } }} />}
            onClick={() => navigate("/admin/map")}
            sx={{ 
              backgroundColor: '#3b82f6',
              color: '#ffffff',
              fontWeight: 600,
              textTransform: 'none',
              py: { xs: 1, sm: 1.2 },
              fontSize: { xs: '0.85rem', sm: '0.9rem' },
              borderRadius: 1.5,
              boxShadow: '0 4px 12px rgba(59, 130, 246, 0.4)',
              '&:hover': {
                backgroundColor: '#2563eb',
                boxShadow: '0 6px 16px rgba(59, 130, 246, 0.5)',
                transform: 'translateY(-2px)',
              },
              transition: 'all 0.3s ease'
            }}
          >
            Ouvrir la carte
          </Button>
        </Box>
      </Box>
    </Box>
  );

  if (lgUp) {
    return (
      <Drawer
        anchor="left"
        open
        PaperProps={{
          sx: {
            backgroundColor: 'transparent',
            color: 'common.white',
            width: { xs: 260, sm: 280 },
            border: 'none',
            boxShadow: '4px 0 24px rgba(0, 0, 0, 0.12)'
          }
        }}
        variant="permanent"
      >
        {content}
      </Drawer>
    );
  }

  return (
    <Drawer
      anchor="left"
      onClose={onClose}
      open={open}
      PaperProps={{
        sx: {
          backgroundColor: 'transparent',
          color: 'common.white',
          width: { xs: 260, sm: 280 },
          border: 'none'
        }
      }}
      sx={{ zIndex: (theme) => theme.zIndex.appBar + 100 }}
      variant="temporary"
    >
      {content}
    </Drawer>
  );
};

SideNav.propTypes = {
  onClose: PropTypes.func,
  open: PropTypes.bool
};

export default SideNav;