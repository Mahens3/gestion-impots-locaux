import baseUrl from 'core/basename';
import { BrowserRouter } from 'react-router-dom';
import "presentation/assets/style/style.css"
import MainRoute, { OtherRoute } from 'core/routes';

function App() {
    return (
        <BrowserRouter basename={baseUrl}>
            <MainRoute/>
            <OtherRoute/>
        </BrowserRouter>
    )
}

export default App;
