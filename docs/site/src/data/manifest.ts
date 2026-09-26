import rawManifest from "../../../build/manifest.json";

export interface BaseEntry {
  name: string;
  image: string;
  tag_suffix: string;
  pkg: string;
  versions: string[];
}

export interface LanguageEntry {
  name: string;
  versions: string[];
  jdk?: string[];
  pm?: string[];
  bases: string[];
}

export interface Manifest {
  default_priv_tool: string;
  latest: string;
  priv_tools: string[];
  default_versions: Record<string, string>;
  bases: BaseEntry[];
  languages: LanguageEntry[];
}

export const manifest = rawManifest as Manifest;

// Cache VOLUME dirs per language, grounded in .docker/*.Dockerfile
// VOLUME declarations and README.md / dockerhub.README.md tables.
// Manually synced — update alongside any Dockerfile cache change.
export const LANGUAGE_CACHES: Record<string, string[]> = {
  java: [".gradle", ".m2/repository"],
  go: ["go/pkg", "go/bin"],
  rust: [".cargo/registry", ".cargo/git", ".cargo/bin"],
  python: [".venv", ".cache/uv", ".local/share/uv/python"],
  dotnet: [".nuget/packages"],
  flutter: [".pub-cache", ".gradle", ".android"],
  bun: [".bun"],
  zig: [".cache/zig"],
  c: [".cache/ccache"],
  cpp: [".cache/ccache"],
  clojure: [".m2/repository"],
  lua: [".luarocks"],
  elixir: [".mix", ".hex"],
  haskell: [".ghcup", ".stack", ".cabal"],
  node: [".npm", ".yarn", ".local/share/pnpm"],
  assembly: [],
  cobol: [],
  julia: [".julia"],
  scala: [".cache/coursier", ".sbt", ".ivy2"],
  delphi: [".fppkg"],
  perl: ["perl5", ".cpan", ".cpanm"],
  php: [".composer"],
  r: [".R/library", ".cache/R"],
  ruby: [".gem", ".bundle"],
  smalltalk: [".cache/pharo"],
  basic: [],
  ada: [".cache/ccache"],
  lisp: ["quicklisp", ".cache/common-lisp"],
};

export const LANGUAGE_NOTES: Record<string, string> = {
  delphi: "Free Pascal in Delphi-compatibility mode (no headless Embarcadero distribution exists)",
  smalltalk: "Pharo (GNU Smalltalk is unmaintained)",
  flutter: "Bundles JDK + Android SDK; JDK 25 default, -jdk21 variant",
  node: "yarn (Berry) default; -npm / -pnpm variants",
  python: "uv-managed",
  dotnet: "glibc-only",
  elixir: "glibc-only",
  haskell: "glibc-only",
};

export interface CatalogRow {
  name: string;
  versions: string[];
  distros: string[];
  caches: string[];
  note?: string;
}

export function languageCatalog(): CatalogRow[] {
  return manifest.languages.map((l) => ({
    name: l.name,
    versions: l.versions,
    distros: l.bases,
    caches: LANGUAGE_CACHES[l.name] ?? [],
    note: LANGUAGE_NOTES[l.name],
  }));
}

export function languageTags(name: string): string[] {
  const lang = manifest.languages.find((l) => l.name === name);
  if (!lang) return [];
  const jdks = lang.jdk?.length ? lang.jdk : [""];
  const pms = lang.pm?.length ? lang.pm : [""];
  const tags: string[] = [];
  for (const v of lang.versions) {
    for (const d of lang.bases) {
      jdks.forEach((jdk, i) => {
        pms.forEach((pm, j) => {
          const jdkSuffix = jdk && i > 0 ? `-jdk${jdk}` : "";
          const pmSuffix = pm && j > 0 ? `-${pm}` : "";
          tags.push(`${name}-${v}${jdkSuffix}${pmSuffix}-${d}`);
        });
      });
    }
  }
  return tags;
}

export function baseTags(): string[] {
  const tags: string[] = [];
  for (const b of manifest.bases) {
    for (const v of b.versions) {
      for (const p of manifest.priv_tools) {
        tags.push(p === manifest.default_priv_tool ? `${b.name}-${v}` : `${b.name}-${v}-${p}`);
      }
    }
  }
  return tags;
}
