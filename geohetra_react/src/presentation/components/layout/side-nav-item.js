import { Box, ButtonBase, alpha } from '@mui/material';
import { NavLink } from 'react-router-dom';

export const SideNavItem = (props) => {
  const { active = false, path, disabled, icon, title } = props;

  return (
    <li style={{ listStyle: 'none' }}>
      <NavLink
        style={{
          textDecoration: 'none',
          color: 'white'
        }}
        to={path}
      >
        <ButtonBase
          disabled={disabled}
          style={{
            width: '100%'
          }}
          sx={{
            alignItems: 'center',
            borderRadius: 1.5,
            display: 'flex',
            justifyContent: 'flex-start',
            px: { xs: 1.5, sm: 2 },
            py: { xs: 1.25, sm: 1.5 },
            my: 0.5,
            textAlign: 'left',
            position: 'relative',
            overflow: 'hidden',
            transition: 'all 0.2s ease',
            
            // État actif
            ...(active && {
              backgroundColor: alpha('#ffffff', 0.15),
              boxShadow: '0 2px 8px rgba(0, 0, 0, 0.15)',
              '&::before': {
                content: '""',
                position: 'absolute',
                left: 0,
                top: '50%',
                transform: 'translateY(-50%)',
                width: '4px',
                height: '60%',
                backgroundColor: '#60a5fa',
                borderRadius: '0 4px 4px 0',
              }
            }),
            
            // Hover
            '&:hover': {
              backgroundColor: alpha('#ffffff', active ? 0.15 : 0.1),
              transform: 'translateX(4px)',
              ...(active && {
                boxShadow: '0 4px 12px rgba(0, 0, 0, 0.2)',
              })
            },

            // Disabled
            ...(disabled && {
              opacity: 0.5,
              cursor: 'not-allowed',
              '&:hover': {
                backgroundColor: 'transparent',
                transform: 'none',
              }
            })
          }}
        >
          {/* Icône */}
          {icon && (
            <Box
              component="span"
              sx={{
                alignItems: 'center',
                color: alpha('#ffffff', 0.7),
                display: 'inline-flex',
                justifyContent: 'center',
                mr: { xs: 1.25, sm: 1.5 },
                fontSize: { xs: '1.15rem', sm: '1.25rem' },
                transition: 'all 0.2s ease',
                ...(active && {
                  color: '#60a5fa',
                  transform: 'scale(1.1)',
                }),
                ...(disabled && {
                  color: alpha('#ffffff', 0.4),
                })
              }}
            >
              {icon}
            </Box>
          )}
          
          {/* Titre */}
          <Box
            component="span"
            sx={{
              color: alpha('#ffffff', 0.85),
              flexGrow: 1,
              fontSize: { xs: '0.85rem', sm: '0.9rem' },
              fontWeight: 500,
              lineHeight: '24px',
              whiteSpace: 'nowrap',
              transition: 'all 0.2s ease',
              ...(active && {
                color: '#ffffff',
                fontWeight: 600,
              }),
              ...(disabled && {
                color: alpha('#ffffff', 0.4),
              })
            }}
          >
            {title}
          </Box>

          {/* Badge pour item actif (optionnel) */}
          {active && (
            <Box
              component="span"
              sx={{
                width: { xs: 5, sm: 6 },
                height: { xs: 5, sm: 6 },
                borderRadius: '50%',
                backgroundColor: '#60a5fa',
                ml: 1,
                animation: 'pulse 2s ease-in-out infinite',
                '@keyframes pulse': {
                  '0%, 100%': {
                    opacity: 1,
                  },
                  '50%': {
                    opacity: 0.5,
                  }
                }
              }}
            />
          )}
        </ButtonBase>
      </NavLink>
    </li>
  );
};