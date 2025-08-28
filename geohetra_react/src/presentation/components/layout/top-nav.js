import { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import Bars3Icon from '@mui/icons-material/Menu';
import {
  Box,
  IconButton,
  Menu,
  MenuItem,
  Stack,
  SvgIcon,
} from '@mui/material';
import { alpha } from '@mui/material/styles';
import { useNavigate } from 'react-router-dom';
import { AccountBox, History, Logout, Settings } from '@mui/icons-material';

const SIDE_NAV_WIDTH = 280;
const TOP_NAV_HEIGHT = 64;

const TopNav = (props) => {
  const navigate = useNavigate()
  const [anchorEl, setAnchorEl] = useState(null);

  const handleClick = (event) => {
    setAnchorEl(event.currentTarget);
  };

  const handleClose = () => {
    setAnchorEl(null);
  };

  const handleOptionClick = (option) => {
    handleClose();
  };

  const { onNavOpen } = props;
  const [lgUp, setLgUp] = useState(window.matchMedia('(min-width: 1280px)').matches);

  useEffect(() => {

    const handleResize = () => {
      setLgUp(window.matchMedia('(min-width: 1280px)').matches);
    };

    window.addEventListener('resize', handleResize);

    return () => {
      window.removeEventListener('resize', handleResize);
    };
  }, []);

  return (
    <>
      <Box
        component="header"
        sx={{
          backdropFilter: 'blur(6px)',
          backgroundColor: alpha('#000', 0.1),
          position: 'sticky',
          left: lgUp ? `${SIDE_NAV_WIDTH}px` : 0,
          top: 0,
          width: lgUp ? `calc(100% - ${SIDE_NAV_WIDTH}px)` : '100%',
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
            spacing={2}
          >
            {!lgUp && (
              <IconButton onClick={onNavOpen}>
                <SvgIcon fontSize="small">
                  <Bars3Icon />
                </SvgIcon>
              </IconButton>
            )}
          </Stack>
          <Stack
            alignItems="center"
            direction="row"
            spacing={2}
          >
            <div>
              <IconButton onClick={handleClick}>
                <Settings />
              </IconButton>
              <Menu
                id="dropdown-menu"
                anchorEl={anchorEl}
                keepMounted
                open={Boolean(anchorEl)}
                onClose={handleClose}
              >
                <MenuItem onClick={() => handleOptionClick('Option 1')}><History  sx={{ mr : 1}} /> Historique</MenuItem>
                <MenuItem onClick={() => handleOptionClick('Option 2')}><AccountBox sx={{ mr : 1}} /> Votre profil</MenuItem>
                <MenuItem sx={{
                  color : "red"
                }} onClick={() => {
                  localStorage.removeItem("_token")
                  localStorage.removeItem("search")
                  localStorage.removeItem("page")
                  navigate("/")
                }}><Logout sx={{ mr : 1}} /> Se deconnecter</MenuItem>
              </Menu>
            </div>


          </Stack>
        </Stack>
      </Box>
    </>
  );
};

TopNav.propTypes = {
  onNavOpen: PropTypes.func,
};

export default TopNav;
