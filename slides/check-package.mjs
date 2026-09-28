import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import crypto from "node:crypto";
import JSZip from "jszip";
import { deck } from "./content.mjs";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const v02 = process.argv.includes("--v02");
const v03 = process.argv.includes("--v03");
if (v02 && v03) throw Error("Choose one deck version");
const folder = path.join(root, "slides", v03 ? "v03" : v02 ? "v02" : "dist");
const file = path.join(folder, v03 ? "tribal-knowledge-to-code-v03.pptx" : v02 ? "tribal-knowledge-to-code-v02-draft.pptx" : "tribal-knowledge-to-code.pptx");
const data = fs.readFileSync(file);
const zip = await JSZip.loadAsync(data, { checkCRC32: true });
const names = Object.keys(zip.files);
const slides = names.filter(n => /^ppt\/slides\/slide\d+\.xml$/.test(n));
const notes = names.filter(n => /^ppt\/notesSlides\/notesSlide\d+\.xml$/.test(n));
if (slides.length !== 12 || notes.length !== 12) throw Error("Expected 12 slides and notes parts");
const manifest = JSON.parse(fs.readFileSync(path.join(folder, "build-manifest.json")));
if (manifest.pptxSha256 !== crypto.createHash("sha256").update(data).digest("hex")) throw Error("Stale build manifest");
if (v02 || v03) {
  const mediaHashes = new Set(await Promise.all(names.filter(n => /^ppt\/media\/.*\.(png|jpe?g)$/i.test(n))
    .map(async name => crypto.createHash("sha256").update(await zip.file(name).async("nodebuffer")).digest("hex"))));
  for (const asset of [...manifest.images, manifest.headshot]) {
    if (!mediaHashes.has(asset.sha256)) throw Error(`Missing or changed embedded image: ${asset.sha256}`);
  }
}
for (let i = 1; i <= 12; i++) {
  const xml = await zip.file(`ppt/slides/slide${i}.xml`).async("string");
  const note = await zip.file(`ppt/notesSlides/notesSlide${i}.xml`).async("string");
  if (!note.includes(deck.slides[i - 1].id) || !note.includes("Fallback:") || !note.includes("Transition:")) throw Error(`Incomplete notes ${i}`);
  for (const match of xml.matchAll(/<a:rPr\b[^>]*\bsz="(\d+)"/g)) {
    if (Number(match[1]) < 2400) throw Error(`Small projected text on ${i}`);
  }
  if (/C:\\Users|D:\\events|D:\\elbruno|\u2014/.test(xml + note)) throw Error("Local/private path or forbidden punctuation in deck");
}
for (const name of names.filter(n => n.endsWith(".rels"))) {
  const xml = await zip.file(name).async("string");
  for (const match of xml.matchAll(/<Relationship\b([^>]+)\/>/g)) {
    if (/TargetMode="External"/.test(match[1])) continue;
    const target = /Target="([^"]+)"/.exec(match[1])?.[1];
    if (!target) throw Error("Missing relationship target");
    const base = name === "_rels/.rels" ? "" : path.posix.dirname(path.posix.dirname(name));
    const resolved = path.posix.normalize(path.posix.join(base, target));
    if (!zip.file(resolved)) throw Error(`Broken package relationship ${name}: ${resolved}`);
  }
}
console.log("PPTX CRC, 12 slides, 12 notes parts, relationships, font minimum and exact build hash: pass");
