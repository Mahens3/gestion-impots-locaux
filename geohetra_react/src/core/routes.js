import Login from 'presentation/pages/login';
// import Coefficient from 'presentation/pages/coefficient';
import Construction from 'presentation/pages/listConstruction';
import AboutConstruction from 'presentation/pages/aboutConstruction';
import AvisImposition from 'presentation/pages/avis';
import Dashboard from 'presentation/pages/dashboard';
import Suivi from 'presentation/pages/suivi';
import Carte from 'presentation/pages/map';
import { Routes, Route } from 'react-router-dom';
import Main from 'presentation/main';
import Home from 'presentation/pages/home';
import AboutConstructionOut from 'presentation/pages/aboutConstructionOut';
import Distribution from 'presentation/pages/adjoint/distribution';


export const OtherRoute = () => {
    return (
        <Routes>
            <Route path="/login" element={<Login />} />
            <Route path="/" element={<Home />} />
            <Route path="/about/:id" element={<AboutConstructionOut />} />
        </Routes>
    )
}

const MainRoute = () => {
    return (
        <Routes>
            <Route
                path='/admin'
                element={<Main />}
            >
                <Route path='distribution' element={<Distribution/>}/>
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
    )
}

export default MainRoute