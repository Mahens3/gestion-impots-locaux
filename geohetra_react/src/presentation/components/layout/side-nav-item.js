import { Box, ButtonBase } from '@mui/material';
import { NavLink } from 'react-router-dom';

export const SideNavItem = (props) => {
  const { active = false, path, disabled, icon, title } = props;

  return (
    <li
    >
      <NavLink
        style={{
          textDecoration : "none",
          color : "white"
        }}
        to={path}
      >
        <ButtonBase
          style={{
            width: "100%"
          }}
          sx={{
            alignItems: 'center',
            borderRadius: 1,
            display: 'flex',
            justifyContent: 'flex-start',
            pl: '16px',
            pr: '16px',
            py: '7px',
            my : 1,
            textAlign: 'left',
            ...(document.location.href.includes(path) && {
              backgroundColor: 'rgba(255, 255, 255, 0.09)'
            }),
            '&:hover': {
              backgroundColor: 'rgba(255, 255, 255, 0.09)'
            }
          }}
        >
          {icon && (
            <Box
              component="span"
              sx={{
                alignItems: 'center',
                color: 'neutral.400',
                display: 'inline-flex',
                justifyContent: 'center',
                pr: 2,
                ...(active && {
                  color: 'success.main'
                })
              }}
            >
              {icon}
            </Box>
          )}
          <Box
            component="span"
            sx={{
              color: 'neutral.400',
              flexGrow: 1,
              fontSize: 14,
              fontWeight: 600,
              lineHeight: '24px',
              whiteSpace: 'nowrap',
              ...(active && {
                color: 'common.white'
              }),
              ...(disabled && {
                color: 'neutral.500'
              })
            }}
          >
            {title}
          </Box>
        </ButtonBase>
      </NavLink>
    </li>
  );
};

