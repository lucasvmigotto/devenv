import { HashRouter, Route, Routes } from "react-router-dom";
import { Layout } from "./components/Layout";
import { Architecture } from "./pages/Architecture";
import { Catalog } from "./pages/Catalog";
import { Development } from "./pages/Development";
import { Overview } from "./pages/Overview";
import { Usage } from "./pages/Usage";

// HashRouter: R2 static hosting has no SPA fallback rewrites,
// so hash-based routing keeps deep links working with zero server config.
// The docs-hub prefix lives in the URL pathname via Vite's `base`; the hash
// carries the route on its own. A hash router must NOT set `basename`: React
// Router would look for the prefix inside the hash, match nothing, and render
// a blank page.
export function App() {
  return (
    // Matches the docs-hub prefix (ADR 0004 in lucas/docs); derived from the
    // Vite base so it tracks VITE_BASE_PATH.
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
