/* eslint-disable no-unused-vars */
import { SvgIcon } from '@mui/material';
import { CreditScore, Dashboard, FilePresent, Home } from '@mui/icons-material';


export const items = [
  {
    title: 'Tableau de bord',
    path: '/admin/dashboard',
    icon: (
      <SvgIcon fontSize="small">
        <Dashboard />
      </SvgIcon>
    ),
  },
  {
    title: 'Construction',
    path: '/admin/construction',
    icon: (
      <SvgIcon fontSize="small">
        <Home />
      </SvgIcon>
    ),
  },
  {
    title: "Avis d'imposition",
    path: '/admin/avis',
    icon: (
      <SvgIcon fontSize="small">
        <FilePresent />
      </SvgIcon>
    ),
  },
  {
    title: 'Suivi',
    path: '/admin/construction/suivi',
    icon: (
      <SvgIcon fontSize="small">
        <CreditScore />
      </SvgIcon>
    ),
  }
];
