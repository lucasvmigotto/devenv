import { useMemo, useState } from "react";
import { Badge, TagTable } from "../components/ui";
import { languageCatalog, languageTags } from "../data/manifest";

export function Catalog() {
  const [query, setQuery] = useState("");
  const [distro, setDistro] = useState("all");
  const catalog = useMemo(() => languageCatalog(), []);
  const distros = useMemo(
    () => ["all", ...Array.from(new Set(catalog.flatMap((c) => c.distros))).sort()],
    [catalog],
  );

  const filtered = catalog.filter((c) => {
    const q = query.trim().toLowerCase();
    const matchQ =
      !q || c.name.includes(q) || c.caches.some((cache) => cache.toLowerCase().includes(q));
    const matchD = distro === "all" || c.distros.includes(distro);
    return matchQ && matchD;
  });

  const [expanded, setExpanded] = useState<string | null>(null);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-white">Image catalog</h1>
        <p className="mt-2 max-w-3xl text-slate-400">
          All {catalog.length} language images, generated from <Badge>build/manifest.json</Badge> —
          the same file CI builds from.
        </p>
      </div>

      <div className="flex flex-wrap gap-3">
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Filter by language or cache dir…"
          className="w-72 rounded-lg border border-slate-700 bg-slate-900 px-3 py-2 text-sm text-slate-100 placeholder:text-slate-500"
        />
        <select
          value={distro}
          onChange={(e) => setDistro(e.target.value)}
          className="rounded-lg border border-slate-700 bg-slate-900 px-3 py-2 text-sm text-slate-100"
        >
          {distros.map((d) => (
            <option key={d} value={d}>
              {d === "all" ? "all distros" : d}
            </option>
          ))}
        </select>
      </div>

      <TagTable
        headers={["Language", "Versions", "Distros", "Caches ($HOME)", "Notes"]}
        rows={filtered.map((c) => [
          c.name,
          c.versions.join(", "),
          c.distros.join(", "),
          c.caches.length ? c.caches.join(", ") : "(stateless)",
          c.note ?? "—",
        ])}
      />

      <div className="space-y-2">
        <h2 className="text-xl font-semibold text-sky-300">Exact tags per language</h2>
        <p className="text-sm text-slate-400">
          Click a language to expand every tag CI publishes for it.
        </p>
        <div className="grid gap-2 md:grid-cols-2">
          {filtered.map((c) => (
            <div key={c.name} className="rounded-lg border border-slate-800 bg-slate-900/60 p-3">
              <button
                type="button"
                onClick={() => setExpanded(expanded === c.name ? null : c.name)}
                className="flex w-full items-center justify-between text-left text-sm font-semibold text-slate-100"
              >
                <span className="font-mono">{c.name}</span>
                <span className="text-slate-500">{expanded === c.name ? "▾" : "▸"}</span>
              </button>
              {expanded === c.name && (
                <ul className="mt-2 space-y-1 font-mono text-xs text-sky-200">
                  {languageTags(c.name).map((t) => (
                    <li key={t}>lucasvmigotto/devenv:{t}</li>
                  ))}
                </ul>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
