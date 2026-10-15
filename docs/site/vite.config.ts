import { defineConfig, loadEnv } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";
import { resolve } from "node:path";
import pkg from "./package.json" with { type: "json" };
import { footerVersions, gitInfo, label } from "./scripts/version.mjs";

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), "");
  const siteName =
    process.env.VITE_APP_SITE_NAME ??
    env.VITE_APP_SITE_NAME ??
    "https://devenv.lucasvmigotto.me";
  // The footer's versions: devenv's release tag, then the site's own
  // (package.json), each linked to the tree it was built from.
  const versions = footerVersions({
    repoUrl: "https://github.com/lucasvmigotto/devenv",
    name: "devenv",
    docsVersion: pkg.version,
    docsPath: "docs/site",
    git: gitInfo(resolve(__dirname, "../..")),
  }).map((v) => ({ ...v, label: label(v) }));

  return {
    // Deployed under the docs-hub prefix /<repo>/ (ADR 0001 in lucas/docs).
    // CI sets VITE_BASE_PATH from github.event.repository.name; the local
    // default keeps `vite preview` at the same path as production.
    base: process.env["VITE_BASE_PATH"] ?? "/devenv/",
    plugins: [
      tailwindcss(),
      react(),
      {
        name: "html-app-site-name",
        transformIndexHtml(html) {
          return html.replaceAll("%APP_SITE_NAME%", siteName);
        },
      },
    ],
    resolve: {
      alias: {
        "@": resolve(__dirname, "src"),
      },
    },
    define: {
      __APP_VERSION__: JSON.stringify(pkg.version),
      __VERSIONS__: JSON.stringify(versions),
      __APP_SITE_NAME__: JSON.stringify(siteName),
    },
  };
});
