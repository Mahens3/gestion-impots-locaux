import { Routes, Route } from "react-router-dom";

import Login from "presentation/pages/login";
import Construction from "presentation/pages/listConstruction";
import AboutConstruction from "presentation/pages/aboutConstruction";
import AvisImposition from "presentation/pages/avis";
import Dashboard from "presentation/pages/dashboard";
import Suivi from "presentation/pages/suivi";
import Carte from "presentation/pages/map";
import Main from "presentation/main";
import Home from "presentation/pages/home";
import AboutConstructionOut from "presentation/pages/aboutConstructionOut";
import Distribution from "presentation/pages/adjoint/distribution";

export const AppRoutes = () => {
  return (
    <Routes>
      {/* PUBLIC */}
      <Route path="/login" element={<Login />} />
      <Route path="/" element={<Home />} />
      <Route path="/about/:id" element={<AboutConstructionOut />} />

      {/* ADMIN */}
      <Route path="/admin" element={<Main />}>
        <Route path="distribution" element={<Distribution />} />
        <Route path="construction" element={<Construction />} />
        <Route path="construction/new/:geometry" element={<AboutConstruction />} />
        <Route path="construction/:id" element={<AboutConstruction />} />
        <Route path="avis" element={<AvisImposition />} />
        <Route path="avis/:id" element={<AvisImposition />} />
        <Route path="dashboard" element={<Dashboard />} />
        <Route path="map" element={<Carte />} />
        <Route path="map/idfoko=:idfoko/numcons=:numcons" element={<Carte />} />
        <Route path="construction/suivi" element={<Suivi />} />
      </Route>
    </Routes>
  );
};
