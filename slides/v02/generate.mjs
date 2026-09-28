import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { fileURLToPath } from "node:url";
import pptxgen from "pptxgenjs";
import { deck, notesFor } from "./content.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, "..", "..");
const hash = file => crypto.createHash("sha256").update(fs.readFileSync(file)).digest("hex");
const review = JSON.parse(fs.readFileSync(path.join(here, "asset-review.json"), "utf8"));
for (const asset of review.assets) {
  if (hash(path.join(here, "images", `${asset.id}.png`)) !== asset.sha256) throw Error(`Unreviewed asset bytes: ${asset.id}`);
}
const headshot = path.resolve(here, review.headshot.path);
if (hash(headshot) !== review.headshot.sha256) throw Error("Headshot changed since local review");
if (deck.slides.length !== 12) throw Error("The narrative stays at 12 slides");
const nullSetting = fs.readFileSync(path.join(root, "src", "Northwind.Quotes", "QuoteJson.cs"), "utf8")
  .split(/\r?\n/).find(line => line.includes("DefaultIgnoreCondition =")).trim().replace(/,$/, "");
for (const item of deck.slides) {
  if (!item.kicker || !item.layout || !notesFor(item).includes("Fallback:")) throw Error(`Incomplete slide: ${item.id}`);
  for (const text of [item.title, item.kicker, item.takeaway]) {
    if (text.includes("\u2014") || text.endsWith(".")) throw Error(`Slide punctuation: ${item.id}`);
  }
}
if (process.argv.includes("--check")) {
  console.log("v02: twelve slides, source excerpts, notes, headshot and four reviewed Flare image hashes: pass");
  process.exit(0);
}

const pptx = new pptxgen();
pptx.layout = "LAYOUT_WIDE";
pptx.title = `${deck.title} | v02 draft`;
pptx.author = deck.author;
pptx.subject = "Draft visual redesign; synthetic local demo; conceptual illustrations, not agent evidence";
pptx.company = "Bruno Capuano";
pptx.lang = "en-US";
pptx.theme = { headFontFace: "Aptos Display", bodyFontFace: "Aptos", lang: "en-US" };
const C = { paper: "FFFFFF", ink: "190649", purple: "512BD4", lilac: "B9AAEE", pale: "EEEAFB",
  muted: "514567", line: "C8BDF0", rose: "FBE5F6" };
const geometry = [];
let current;

function rect(slide, x, y, w, h, fill = C.paper, line = C.ink, width = 1.3) {
  slide.addShape(pptx.ShapeType.rect, {
    x, y, w, h, fill: { color: fill },
    line: { color: line, width, transparency: width ? 0 : 100 }
  });
}
function txt(slide, text, x, y, w, h, size = 28, extra = {}) {
  if (size < 24 || x < 0.5 || y < 0.25 || x + w > 12.84 || y + h > 7.12) {
    throw Error(`Text geometry/font outside contract: ${current.id} ${text}`);
  }
  slide.addText(text, { x, y, w, h, margin: 0, fontFace: "Aptos", fontSize: size,
    color: C.ink, valign: "mid", breakLine: false, ...extra });
  geometry.push({ id: current.id, text, x, y, w, h, fontSize: size });
}
function badge(slide, text, x, y, w, fill = C.pale, color = C.purple) {
  rect(slide, x, y, w, 0.58, fill, fill, 0);
  txt(slide, text, x + 0.13, y + 0.04, w - 0.26, 0.5, 24, { bold: true, color });
}
function arrow(slide, x, y, w = 0.5, h = 0.25, rotate = 0) {
  slide.addShape(pptx.ShapeType.rightArrow, { x, y, w, h, rotate,
    fill: { color: C.purple }, line: { color: C.purple, transparency: 100 } });
}
function image(slide, id, x = 8.3, y = 2.14, side = 4.0) {
  const file = path.join(here, "images", `${id}.png`);
  rect(slide, x + 0.08, y + 0.08, side, side, C.lilac, C.lilac, 0);
  rect(slide, x, y, side, side);
  slide.addImage({ path: file, x: x + 0.035, y: y + 0.035, w: side - 0.07, h: side - 0.07,
    sizing: { type: "contain", w: side - 0.07, h: side - 0.07 },
    altText: JSON.parse(fs.readFileSync(path.join(here, "images", `${id}.json`), "utf8")).altText });
}
function header(slide, item) {
  txt(slide, item.kicker, 0.65, 0.32, 11.9, 0.42, 24, { color: C.purple, bold: true });
  txt(slide, item.title, 0.65, 0.87, 12, 1.36, 38, { fontFace: "Aptos Display", bold: true });
  for (let row = 0; row < 3; row++) for (let col = 0; col < 7; col++) {
    slide.addShape(pptx.ShapeType.ellipse, { x: 11.75 + col * 0.13, y: 0.36 + row * 0.1,
      w: 0.023, h: 0.023, fill: { color: C.lilac }, line: { transparency: 100, color: C.lilac } });
  }
}
function takeaway(slide, item) {
  rect(slide, 0.65, 6.52, 12, 0.58, C.pale, C.pale, 0);
  txt(slide, item.takeaway, 0.84, 6.57, 11.62, 0.48, 24, { color: C.purple, bold: true });
}
function row(slide, title, detail, y, index) {
  rect(slide, 0.72, y + 0.08, 0.54, 0.54, C.purple, C.purple, 0);
  txt(slide, `R${index}`, 0.76, y + 0.1, 0.46, 0.5, 24, { color: C.paper, bold: true, align: "center" });
  txt(slide, title, 1.48, y, 5.8, 0.53, 29, { bold: true });
  txt(slide, detail, 1.48, y + 0.52, 5.8, 0.48, 24, { color: C.muted });
}

const pilot = process.argv.includes("--pilot");
const selected = pilot ? deck.slides.filter(s => ["S01", "S06", "S07", "S09"].includes(s.id)) : deck.slides;
for (const item of selected) {
  current = item;
  const slide = pptx.addSlide();
  slide.background = { color: C.paper };
  if (item.layout !== "presenter") header(slide, item);
  takeaway(slide, item);
  slide.addNotes(notesFor(item));

  switch (item.layout) {
    case "presenter":
      txt(slide, item.kicker, 0.65, 0.32, 11.9, 0.42, 24, { color: C.purple, bold: true });
      txt(slide, item.title, 0.65, 1.05, 8.0, 2.0, 46, { bold: true, fontFace: "Aptos Display" });
      txt(slide, "Custom Skills for\nGitHub Copilot Modernization", 0.68, 3.2, 7.7, 1.0, 30, { color: C.purple, bold: true });
      badge(slide, "Bruno Capuano", 0.68, 4.68, 5.4, C.lilac, C.ink);
      txt(slide, "A practical, demo-driven session", 0.68, 5.42, 7.6, 0.65, 26, { color: C.muted });
      rect(slide, 9.02, 1.12, 3.55, 4.88, C.lilac, C.lilac, 0);
      slide.addImage({ path: headshot, x: 8.92, y: 1.02, w: 3.55, h: 4.88,
        sizing: { type: "crop", w: 3.55, h: 4.88 },
        altText: "Bruno Capuano, presenter-supplied photograph" });
      slide.addShape(pptx.ShapeType.rect, { x: 8.92, y: 1.02, w: 3.55, h: 4.88,
        fill: { color: C.paper, transparency: 100 }, line: { color: C.ink, width: 1.5 } });
      break;
    case "proof":
      rect(slide, 0.72, 2.42, 5.35, 3.6, C.pale);
      txt(slide, "PARTNER QUOTE", 1.02, 2.73, 4.65, 0.5, 24, { color: C.purple, bold: true });
      txt(slide, "3 x 33.35 = 100.05", 1.02, 3.36, 4.65, 0.5, 26);
      txt(slide, "10% discount: -10.01", 1.02, 3.99, 4.65, 0.45, 24, { color: C.muted });
      txt(slide, "Shipping: +12.00", 1.02, 4.53, 4.65, 0.45, 24, { color: C.muted });
      txt(slide, "Total  102.04", 1.02, 5.14, 4.65, 0.7, 38, { bold: true });
      [
        ["Technical", "Does it build?"],
        ["Business", "Does pricing stay correct?"],
        ["Organizational", "Does it follow our rules?"]
      ].forEach(([title, body], i) => {
        const y = 2.5 + i * 1.23;
        txt(slide, title, 6.65, y, 5.45, 0.5, 30, { bold: true, color: C.purple });
        txt(slide, body, 6.65, y + 0.53, 5.45, 0.5, 26);
      });
      break;
    case "knowledge":
      row(slide, "Pricing exceptions", "Discounts and shipping thresholds", 2.18, 1);
      row(slide, "Compatibility contract", "Enums, nulls and field names", 3.2, 2);
      row(slide, "Approved audit path", "One abstraction, safe event fields", 4.22, 3);
      row(slide, "Safe diagnostics", "No customer data on failure", 5.24, 4);
      image(slide, item.image);
      break;
    case "context-map": {
      const cards = [
        ["Prompt", "Today's task", "Replace the library"],
        ["Instructions", "Project conventions", "Build and safety"],
        ["Skill", "Specialized workflow", "Rules and examples"],
        ["Tests + CI", "Observable evidence", "Defined pass / fail"]
      ];
      cards.forEach(([title, label, body], i) => {
        const y = 2.27 + i * 0.86;
        rect(slide, 0.72, y, 11.9, 0.74, i === 2 ? C.pale : C.paper);
        txt(slide, title, 0.96, y + 0.09, 2.66, 0.56, 29, { bold: true, color: C.purple });
        txt(slide, label, 3.9, y + 0.09, 4.0, 0.56, 26, { bold: true });
        txt(slide, body, 8.43, y + 0.1, 3.93, 0.54, 24, { color: C.muted });
      });
      txt(slide, "Assess    >    Plan    >    Change    >    Review", 0.72, 5.78, 11.8, 0.5, 26, { bold: true, color: C.purple });
      break;
    }
    case "baseline":
      badge(slide, "BASELINE / NOT-RUN", 0.72, 2.3, 6.7);
      txt(slide, "Newtonsoft.Json", 0.9, 3.08, 6.4, 0.64, 34, { bold: true });
      arrow(slide, 3.86, 3.9, 0.48, 0.32, 90);
      txt(slide, "System.Text.Json", 0.9, 4.47, 6.4, 0.64, 34, { bold: true, color: C.purple });
      txt(slide, "Narrow change\nSame observable behavior", 0.9, 5.26, 6.4, 0.98, 26, { color: C.muted });
      image(slide, item.image);
      break;
    case "rule":
      rect(slide, 0.72, 2.42, 5.55, 3.65, C.pale);
      txt(slide, "THE TEAM NOTE", 1.0, 2.66, 5.0, 0.5, 24, { color: C.purple, bold: true });
      txt(slide, "\"No note yet\" still\nneeds a property", 1.0, 3.35, 5.0, 1.1, 32, { bold: true });
      txt(slide, "Required field, optional value", 1.0, 4.94, 5.0, 0.58, 24, { color: C.muted });
      txt(slide, "THE CONTRACT", 6.83, 2.63, 5.55, 0.5, 24, { color: C.purple, bold: true });
      txt(slide, '"review_note": null', 6.83, 3.38, 5.55, 0.72, 29, { fontFace: "Consolas", bold: true });
      txt(slide, nullSetting.replace(" = ", " =\n"), 6.83, 4.34, 5.55, 1.17, 24, { fontFace: "Consolas" });
      txt(slide, "Assert the parsed JSON shape", 6.83, 5.64, 5.55, 0.5, 24, { color: C.muted });
      break;
    case "skill":
      rect(slide, 0.72, 2.4, 6.7, 1.35, C.pale);
      txt(slide, "SKILL.md", 1.0, 2.57, 6.13, 0.5, 30, { bold: true });
      txt(slide, "name: northwind-modernization", 1.0, 3.1, 6.13, 0.5, 24, { fontFace: "Consolas", color: C.purple });
      txt(slide, "Supporting references", 0.95, 4.05, 6.1, 0.52, 29, { bold: true });
      txt(slide, "Pricing and contract\nAudit and privacy\nReview checklist", 0.95, 4.6, 6.1, 1.48, 26, { color: C.muted, breakLine: false });
      image(slide, item.image);
      break;
    case "guided":
      badge(slide, "GUIDED / NOT-RUN", 0.72, 2.34, 6.7);
      rect(slide, 0.72, 3.15, 6.7, 1.04, C.paper);
      txt(slide, "18 matching source / test files", 0.96, 3.37, 6.2, 0.55, 28, { bold: true });
      rect(slide, 0.72, 4.48, 6.7, 1.04, C.pale);
      txt(slide, "+ 4 self-contained skill files", 0.96, 4.7, 6.2, 0.55, 28, { bold: true, color: C.purple });
      txt(slide, "Fresh conversation. Same core prompt", 0.96, 5.7, 6.2, 0.5, 24, { color: C.muted });
      ["Assess", "Plan", "Change", "Review"].forEach((label, i) => {
        const y = 2.48 + i * 0.98;
        rect(slide, 8.45, y, 3.85, 0.67, i % 2 ? C.paper : C.pale);
        txt(slide, label, 8.67, y + 0.08, 3.41, 0.51, 28, { bold: true, align: "center" });
        if (i < 3) arrow(slide, 10.24, y + 0.76, 0.27, 0.15, 90);
      });
      break;
    case "evidence":
      badge(slide, "BASELINE + GUIDED: NOT-RUN", 0.72, 2.35, 6.7);
      ["Migration + build", "Pricing + JSON contract", "Audit + diagnostics", "Diff scope + review"].forEach((label, i) => {
        const y = 3.14 + i * 0.73;
        rect(slide, 0.94, y + 0.14, 0.25, 0.25, C.paper, C.purple);
        txt(slide, label, 1.47, y, 5.6, 0.55, 28, { bold: true });
      });
      image(slide, item.image);
      break;
    case "loop": {
      const boxes = [
        { x: 0.85, y: 2.4, title: "Version + own", subtitle: "One accountable owner" },
        { x: 7.05, y: 2.4, title: "Review", subtitle: "Intent, examples, tests" },
        { x: 7.05, y: 4.52, title: "Reuse", subtitle: "Try another small change" },
        { x: 0.85, y: 4.52, title: "Maintain", subtitle: "Learn from real failures" }
      ];
      boxes.forEach((box, i) => {
        rect(slide, box.x, box.y, 5.4, 1.38, i % 2 ? C.paper : C.pale);
        txt(slide, box.title, box.x + 0.22, box.y + 0.18, 4.96, 0.52, 30, { bold: true });
        txt(slide, box.subtitle, box.x + 0.22, box.y + 0.83, 4.96, 0.42, 24, { color: C.muted });
      });
      arrow(slide, 6.42, 2.99, 0.42, 0.23);
      arrow(slide, 9.53, 4.0, 0.44, 0.24, 90);
      arrow(slide, 6.42, 5.1, 0.42, 0.23, 180);
      arrow(slide, 3.33, 4.0, 0.44, 0.24, 270);
      break;
    }
    case "action":
      txt(slide, "One task\nOne rule\nOne example", 0.8, 2.52, 6.45, 2.37, 39, { bold: true });
      badge(slide, "Small enough to check", 0.8, 5.45, 6.45, C.lilac, C.ink);
      image(slide, item.image);
      break;
    case "resources":
      rect(slide, 0.72, 2.38, 7.95, 3.65, C.pale);
      txt(slide, "Official agent skills docs", 1.02, 2.68, 7.3, 0.56, 30, {
        bold: true, hyperlink: { url: "https://docs.github.com/en/copilot/concepts/agents/about-agent-skills" }
      });
      txt(slide, "docs.github.com", 1.02, 3.35, 7.3, 0.5, 26, { color: C.purple });
      txt(slide, "Official upgrade docs", 1.02, 4.22, 7.3, 0.56, 30, {
        bold: true, hyperlink: { url: "https://learn.microsoft.com/en-us/dotnet/core/porting/github-copilot-upgrade/overview" }
      });
      txt(slide, "learn.microsoft.com", 1.02, 4.89, 7.3, 0.5, 26, { color: C.purple });
      txt(slide, "Q&A", 9.15, 2.83, 3.0, 1.25, 64, { bold: true, color: C.purple, align: "center" });
      txt(slide, "Sample link pending\npublic verification", 8.98, 4.37, 3.55, 1.47, 24, { color: C.muted, align: "center" });
      break;
    default: throw Error(`Unknown layout ${item.layout}`);
  }
}

const name = pilot ? "tribal-knowledge-to-code-v02-pilot" : "tribal-knowledge-to-code-v02-draft";
const output = path.join(here, `${name}.pptx`);
if (fs.existsSync(output)) {
  const archive = path.join(here, "history");
  fs.mkdirSync(archive, { recursive: true });
  const previous = path.join(archive, `${hash(output)}.pptx`);
  if (!fs.existsSync(previous)) fs.copyFileSync(output, previous);
}
await pptx.writeFile({ fileName: output });
const manifest = {
  schemaVersion: 1, version: deck.version, status: "draft; presenter review pending",
  builtUtc: new Date().toISOString(), node: process.version, pptxgenjs: pptx.version,
  pptxSha256: hash(output), slideCount: selected.length, geometry,
  slides: selected.map(slide => ({ id: slide.id, title: slide.title, notes: notesFor(slide) })),
  sources: ["slides/content.mjs", "slides/v02/content.mjs", "slides/v02/generate.mjs",
    "slides/v02/image-prompts.json", "slides/v02/asset-review.json", "src/Northwind.Quotes/QuoteJson.cs"]
    .map(file => ({ file, sha256: hash(path.join(root, file)) })),
  images: review.assets, headshot: { provenance: review.headshot.provenance, sha256: review.headshot.sha256 }
};
fs.writeFileSync(path.join(here, pilot ? "pilot-manifest.json" : "build-manifest.json"), JSON.stringify(manifest, null, 2) + "\n");
if (!pilot) {
  fs.writeFileSync(path.join(here, "speaker-notes.md"), "# Speaker notes: v02 draft\n\n" +
    "Generated from v02/content.mjs. Original v01 notes are preserved. Designed timing, not a measured rehearsal.\n\n" +
    selected.map(s => `## ${s.id}: ${s.title.replaceAll("\n", " ")}\n\n${notesFor(s)}\n`).join("\n"));
  fs.writeFileSync(path.join(here, "outline.md"), "# Visual outline: v02 draft\n\n" +
    "| ID | Time | Title | Layout | Conceptual image |\n| --- | --- | --- | --- | --- |\n" +
    selected.map(s => `| ${s.id} | ${s.time} | ${s.title.replaceAll("\n", " ")} | ${s.layout} | ${s.image ?? "Editable shapes / presenter photo"} |`).join("\n") + "\n");
}
console.log(`Built ${selected.length} v02 draft slides: ${output}`);
