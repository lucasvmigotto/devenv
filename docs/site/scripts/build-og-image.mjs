import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { Resvg } from "@resvg/resvg-js";

// Rasterize the Open Graph source SVG into a PNG served from /images/.
// Runs before `vite build` (prebuild) so the PNG lands in `public/` and is
// copied verbatim into `dist/`.
//
// The bundled monospace font is passed explicitly: resvg does not resolve
// generic families like `ui-monospace` or fetch fonts over the network, so
// without it the SVG's font-family declarations silently fall back and the
// PNG no longer matches the intended rendering.
const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const source = resolve(root, "public/images/og-image.svg");
const output = resolve(root, "public/images/og-image.png");
const fontDir = resolve(root, "public/assets/fonts");

const svg = readFileSync(source, "utf8");
const png = new Resvg(svg, {
  fitTo: { mode: "width", value: 1200 },
  font: {
    fontDirs: [fontDir],
    loadSystemFonts: false,
    defaultFontFamily: "DejaVu Sans Mono",
  },
})
  .render()
  .asPng();

mkdirSync(dirname(output), { recursive: true });
writeFileSync(output, png);
console.log(`built ${output} (${png.length} bytes)`);
