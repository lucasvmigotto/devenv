import { defineConfig, loadEnv } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";
import { resolve } from "node:path";
import pkg from "./package.json" with { type: "json" };

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), "");
  const siteName =
    process.env.VITE_APP_SITE_NAME ??
    env.VITE_APP_SITE_NAME ??
    "https://devenv.lucasvmigotto.me";

  return {
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
      __APP_SITE_NAME__: JSON.stringify(siteName),
    },
  };
});
