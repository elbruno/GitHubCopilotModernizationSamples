import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { fileURLToPath } from "node:url";
import pptxgen from "pptxgenjs";
import { deck, notesFor } from "./content.mjs";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const read = file => fs.readFileSync(path.join(root, file), "utf8");
const sha = bytes => crypto.createHash("sha256").update(bytes).digest("hex");
const source = read("src/Northwind.Quotes/QuoteJson.cs");
const nullLine = source.split(/\r?\n/).find(line => line.includes("DefaultIgnoreCondition =")).trim().replace(/,$/, "");
const skillLine = read(".github/skills/northwind-modernization/SKILL.md").split(/\r?\n/).find(line => line.startsWith("name: "));
if (deck.slides.length !== 12 || new Set(deck.slides.map(s => s.id)).size !== 12) throw Error("Exactly 12 unique slides required");
for (const [index, slide] of deck.slides.entries()) {
  if (slide.id !== `S${String(index + 1).padStart(2, "0")}`) throw Error("Slide order mismatch");
  if (slide.points.length < 3 || slide.points.length > 5 || !slide.transition || !slide.fallback) throw Error(`Incomplete notes: ${slide.id}`);
  for (const text of [slide.title, slide.subtitle ?? "", slide.takeaway, ...slide.labels]) {
    if (text.includes("\u2014") || text.trim().endsWith(".")) throw Error(`Forbidden slide punctuation: ${slide.id}`);
  }
}
if (!nullLine || !skillLine) throw Error("Actual code excerpts unavailable");
if (process.argv.includes("--check")) {
  console.log("12-slide source, notes contract, source excerpts, IDs, and punctuation: pass");
  process.exit(0);
}

const pptx = new pptxgen();
pptx.layout = "LAYOUT_WIDE";
pptx.author = deck.author;
pptx.subject = "Synthetic local dependency modernization with reusable organizational guidance";
pptx.title = deck.title;
pptx.company = "Synthetic demo";
pptx.lang = "en-US";
pptx.theme = { headFontFace: "Aptos Display", bodyFontFace: "Aptos", lang: "en-US" };
const ink = "202137", violet = "6241B8", blue = "2855A6", pale = "F0ECFA", white = "FAFAFD";
const geometry = [];
function text(slide, value, x, y, w, h, size = 26, extra = {}) {
  if (size < 24) throw Error("Projected text must be >=24pt");
  if (x < 0.5 || y < 0.4 || x + w > 12.84 || y + h > 7.05) throw Error(`Text outside margins: ${value}`);
  slide.addText(value, { x, y, w, h, fontSize: size, fontFace: "Aptos", color: ink,
    margin: 0, breakLine: false, valign: "mid", ...extra });
  geometry.push({ slide: pptx._slides.length, text: value, x, y, w, h, fontSize: size });
}
function card(slide, value, x, y, w, h, color = pale, size = 28) {
  slide.addShape(pptx.ShapeType.rect, { x, y, w, h, line: { color, transparency: 100 }, fill: { color } });
  text(slide, value, x + 0.25, y + 0.18, w - 0.5, h - 0.36, size, { bold: true, color: violet });
}
function base(item) {
  const slide = pptx.addSlide();
  slide.background = { color: white };
  if (item.layout !== "hero") text(slide, item.title, 0.65, 0.55, 12, 1.35, 36, { bold: true, fontFace: "Aptos Display" });
  text(slide, item.takeaway, 0.65, 6.2, 12, 0.72, 26, { color: blue, bold: true });
  slide.addNotes(notesFor(item));
  return slide;
}
for (const item of deck.slides) {
  const slide = base(item);
  switch (item.layout) {
    case "hero":
      text(slide, item.title, 0.65, 0.65, 12, 1.6, 42, { bold: true, fontFace: "Aptos Display" });
      text(slide, item.subtitle, 0.65, 2.55, 12, 0.6, 28, { color: violet, bold: true });
      text(slide, "Bruno Capuano", 0.65, 3.35, 11, 0.5, 26);
      item.labels.forEach((label, i) => card(slide, label, 0.65 + i * 4.12, 4.45, 3.8, 1.0, pale, 26));
      break;
    case "three":
      item.labels.forEach((label, i) => card(slide, label, 0.65 + i * 4.12, 2.5, 3.8, 2.2));
      text(slide, "33.35 x 3  |  Partner total: 102.04", 0.65, 5.1, 12, 0.6, 28, { bold: true });
      break;
    case "four":
      item.labels.forEach((label, i) => card(slide, label, 0.65 + (i % 2) * 6.16,
        2.15 + Math.floor(i / 2) * 1.85, 5.82, 1.5));
      break;
    case "demo":
      item.labels.forEach((label, i) => card(slide, label, 0.65 + i * 6.16, 2.35, 5.82, 1.9, pale, 32));
      text(slide, item.badge, 0.65, 4.8, 12, 0.55, 28, { color: violet, bold: true });
      text(slide, "Fallback: explicitly labeled reference walkthrough", 0.65, 5.45, 12, 0.55, 24);
      break;
    case "rule":
      card(slide, item.labels[0], 0.65, 2.2, 5.82, 1.45);
      card(slide, item.labels[1], 6.81, 2.2, 5.82, 1.45);
      text(slide, nullLine.replace(" = ", " =\n"), 0.9, 4.1, 11.5, 1.35, 24, { fontFace: "Consolas", color: blue });
      break;
    case "skill":
      item.labels.forEach((label, i) => card(slide, label, 0.65, 2.15 + i * 1.05, 5.82, 0.82, pale, 26));
      text(slide, skillLine.replace(": ", ":\n"), 7.05, 2.7, 5.3, 1.5, 24, { fontFace: "Consolas", color: blue });
      text(slide, "Task-specific activation\nSelf-contained resources", 7.05, 4.3, 5.3, 1.1, 26);
      break;
    case "checklist":
      item.labels.forEach((label, i) => {
        card(slide, label, 0.65, 2.1 + i * 0.92, 8.4, 0.8, pale, 24);
        text(slide, "Not-run", 9.45, 2.1 + i * 0.92, 3, 0.8, 24, { color: blue });
      });
      break;
    case "flow":
      item.labels.forEach((label, i) => {
        const x = 0.65 + i * 2.46;
        card(slide, label, x, 2.85, 2.14, 1.4, pale, 26);
        if (i < item.labels.length - 1) slide.addShape(pptx.ShapeType.chevron, {
          x: x + 2.19, y: 3.35, w: 0.22, h: 0.35, fill: { color: violet }, line: { transparency: 100, color: violet }
        });
      });
      break;
    case "resources":
      item.labels.forEach((label, i) => card(slide, label, 0.65, 2.1 + i * 1.15, 12, 0.88, pale, 28));
      text(slide, "Q&A", 0.65, 5.65, 12, 0.45, 24, { bold: true });
      break;
    default: throw Error(`Unknown layout ${item.layout}`);
  }
}
const dist = path.join(root, "slides", "dist");
fs.mkdirSync(dist, { recursive: true });
const output = path.join(dist, "tribal-knowledge-to-code.pptx");
// Preserve earlier candidates instead of silently destroying hash-bound evidence.
if (fs.existsSync(output)) {
  const previousHash = sha(fs.readFileSync(output));
  const archive = path.join(dist, "history");
  fs.mkdirSync(archive, { recursive: true });
  const snapshot = path.join(archive, `${previousHash}.pptx`);
  if (!fs.existsSync(snapshot)) fs.copyFileSync(output, snapshot);
}
await pptx.writeFile({ fileName: output });
const manifest = {
  schemaVersion: 1, builtUtc: new Date().toISOString(), node: process.version, pptxgenjs: "4.0.1",
  pptxSha256: sha(fs.readFileSync(output)), slideCount: deck.slides.length,
  status: "built; native and visual review recorded separately",
  sources: ["slides/content.mjs", "slides/generate.mjs", "src/Northwind.Quotes/QuoteJson.cs",
    ".github/skills/northwind-modernization/SKILL.md"].map(file => ({ file, sha256: sha(read(file)) })),
  slides: deck.slides.map(s => ({ id: s.id, title: s.title, notes: notesFor(s) })), geometry
};
fs.writeFileSync(path.join(dist, "build-manifest.json"), JSON.stringify(manifest, null, 2) + "\n");
fs.writeFileSync(path.join(root, "slides", "speaker-notes.md"),
  `# Speaker notes\n\nGenerated from content.mjs. Designed timing, not a measured rehearsal.\n\n` +
  deck.slides.map(s => `## ${s.id}: ${s.title.replaceAll("\n", " ")}\n\n${notesFor(s)}\n`).join("\n"));
fs.writeFileSync(path.join(root, "slides", "outline.md"),
  "# Slide outline\n\nGenerated from content.mjs. Twelve main slides; Q&A keeps slide 12 visible.\n\n" +
  "| ID | Minutes | Title | Takeaway | Layout | Source |\n| --- | --- | --- | --- | --- | --- |\n" +
  deck.slides.map(s => `| ${s.id} | ${s.time} | ${s.title.replaceAll("\n", " ")} | ${s.takeaway} | ${s.layout} | ${s.source} |`).join("\n") + "\n");
console.log(`Built 12 editable slides with notes: ${output}`);
