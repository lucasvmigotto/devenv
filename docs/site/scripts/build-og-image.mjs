import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { Resvg } from "@resvg/resvg-js";

// Rasterize the Open Graph source SVG into a PNG served from /images/.
// Runs before `vite build` (prebuild) so the PNG lands in `public/` and is
// copied verbatim into `dist/`.
const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const source = resolve(root, "public/images/og-image.svg");
const output = resolve(root, "public/images/og-image.png");

const svg = readFileSync(source, "utf8");
const png = new Resvg(svg, { fitTo: { mode: "width", value: 1200 } })
  .render()
  .asPng();

mkdirSync(dirname(output), { recursive: true });
writeFileSync(output, png);
console.log(`built ${output} (${png.length} bytes)`);
