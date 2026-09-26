import { HashRouter, Route, Routes } from "react-router-dom";
import { Layout } from "./components/Layout";
import { Architecture } from "./pages/Architecture";
import { Catalog } from "./pages/Catalog";
import { Development } from "./pages/Development";
import { Overview } from "./pages/Overview";
import { Usage } from "./pages/Usage";

// HashRouter: R2 static hosting has no SPA fallback rewrites,
// so hash-based routing keeps deep links working with zero server config.
export function App() {
  return (
    <HashRouter>
      <Routes>
        <Route element={<Layout />}>
          <Route index element={<Overview />} />
          <Route path="architecture" element={<Architecture />} />
          <Route path="catalog" element={<Catalog />} />
          <Route path="usage" element={<Usage />} />
          <Route path="development" element={<Development />} />
          <Route path="*" element={<Overview />} />
        </Route>
      </Routes>
    </HashRouter>
  );
}
