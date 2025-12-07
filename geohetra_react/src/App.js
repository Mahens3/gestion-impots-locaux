import baseUrl from "core/basename";
import { BrowserRouter } from "react-router-dom";
import "presentation/assets/style/style.css";
import { AppRoutes } from "core/routes";

function App() {
  return (
    <BrowserRouter basename={baseUrl}>
      <AppRoutes />
    </BrowserRouter>
  );
}

export default App;
