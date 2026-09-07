import { NavLink, Outlet } from "react-router-dom";
import { cx } from "./ui";

const LINKS = [
  { to: "/", label: "Overview", end: true },
  { to: "/architecture", label: "Architecture" },
  { to: "/catalog", label: "Image catalog" },
  { to: "/usage", label: "Usage" },
  { to: "/development", label: "Development" },
];

function Nav() {
  return (
    <header className="sticky top-0 z-10 border-b border-slate-800 bg-[#080C14]/95 backdrop-blur">
      <div className="mx-auto flex max-w-6xl items-center gap-6 px-4 py-3">
        <NavLink to="/" className="font-mono text-lg font-bold text-sky-300">
          ≫_ devenv
        </NavLink>
        <nav className="flex flex-wrap gap-1 text-sm">
          {LINKS.map((l) => (
            <NavLink
              key={l.to}
              to={l.to}
              end={l.end}
              className={({ isActive }) =>
                cx(
                  "rounded-md px-3 py-1.5",
                  isActive
                    ? "bg-slate-800 text-white"
                    : "text-slate-400 hover:bg-slate-900 hover:text-slate-200",
                )
              }
            >
              {l.label}
            </NavLink>
          ))}
        </nav>
      </div>
    </header>
  );
}

function Footer() {
  return (
    <footer className="border-t border-slate-800 py-6 text-center text-xs text-slate-500">
      devenv docs v{__APP_VERSION__} — generated from{" "}
      <a className="underline hover:text-slate-300" href={`https://github.com/lucasvmigotto/devenv/tree/${__APP_VERSION__}`}>
        lucasvmigotto/devenv
      </a>
    </footer>
  );
}

export function Layout() {
  return (
    <div className="flex min-h-screen flex-col">
      <Nav />
      <main className="mx-auto w-full max-w-6xl flex-1 space-y-10 px-4 py-8">
        <Outlet />
      </main>
      <Footer />
    </div>
  );
}
