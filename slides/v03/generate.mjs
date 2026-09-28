import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { fileURLToPath } from "node:url";
import pptxgen from "pptxgenjs";
import { deck, session, notesFor } from "./content.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, "../..");
const assetsRoot = path.join(root, "slides/v02");
const hash = file => crypto.createHash("sha256").update(fs.readFileSync(file)).digest("hex");
const assets = JSON.parse(fs.readFileSync(path.join(assetsRoot, "asset-review.json"), "utf8"));
for (const asset of assets.assets) {
  if (hash(path.join(assetsRoot, "images", `${asset.id}.png`)) !== asset.sha256) throw Error(`Changed artwork: ${asset.id}`);
}
const headshot = path.join(assetsRoot, assets.headshot.path);
if (hash(headshot) !== assets.headshot.sha256) throw Error("Headshot hash mismatch");
let cursor = 0;
for (const segment of session.segments) {
  if (segment.start !== cursor || segment.end <= segment.start) throw Error("Session timing has a gap or overlap");
  cursor = segment.end;
  for (const id of segment.slides) if (!deck.slides.some(s => s.id === id && s.segment === segment.id)) throw Error(`Missing slide ${id}`);
  if (segment.prompt && !fs.existsSync(path.join(root, segment.prompt))) throw Error(`Missing prompt ${segment.prompt}`);
}
if (cursor !== 60 || session.segments.filter(s => s.id.startsWith("demo-")).reduce((n,s) => n+s.end-s.start, 0) !== 42) {
  throw Error("Expected 60-minute session with 42 demo minutes");
}
if (deck.slides.length !== 12 || new Set(deck.slides.map(s => s.id)).size !== 12) throw Error("Expected twelve stable slide IDs");
for (const s of deck.slides) {
  const segment = session.segments.find(x => x.id === s.segment);
  const [start, end] = s.time.split("-").map(Number);
  if (start < segment.start || end > segment.end || end <= start) throw Error(`Slide timing mismatch: ${s.id}`);
  if (/\u2014/.test(s.title + s.takeaway) || s.title.endsWith(".") || s.takeaway.endsWith(".")) throw Error("Forbidden punctuation");
}
if (process.argv.includes("--check")) {
  console.log("v03: 12 slides, five demos, 42 demo minutes, 60-minute timeline, prompts and local artwork hashes: pass");
  process.exit(0);
}

const pptx = new pptxgen();
pptx.layout = "LAYOUT_WIDE";
pptx.title = deck.title;
pptx.author = deck.author;
pptx.subject = "v03 skills-first five-demo session; prepared teaching examples are not independent agent captures";
pptx.company = "Bruno Capuano";
pptx.theme = { headFontFace: "Aptos Display", bodyFontFace: "Aptos", lang: "en-US" };
const C = { ink:"190649", purple:"512BD4", lilac:"B9AAEE", pale:"EEEAFB", white:"FFFFFF", muted:"514567", pink:"FBE5F6" };
const geometry = [];
let current;
function box(s,x,y,w,h,fill=C.white) {
  s.addShape(pptx.ShapeType.rect,{x,y,w,h,fill:{color:fill},line:{color:C.ink,width:1.2}});
}
function text(s,t,x,y,w,h,size=28,extra={}) {
  if (size<24 || x<0.5 || y<0.25 || x+w>12.85 || y+h>7.12) throw Error(`Text geometry: ${current.id} ${t}`);
  s.addText(t,{x,y,w,h,fontFace:"Aptos",fontSize:size,color:C.ink,margin:0,valign:"mid",...extra});
  geometry.push({id:current.id,text:t,x,y,w,h,fontSize:size});
}
function band(s,t,x,y,w,fill=C.pale,color=C.purple) {
  s.addShape(pptx.ShapeType.rect,{x,y,w,h:0.6,fill:{color:fill},line:{transparency:100,color:fill}});
  text(s,t,x+0.16,y+0.05,w-0.32,0.5,24,{bold:true,color});
}
function art(s,id) {
  const x=8.3,y=2.2,side=4;
  box(s,x+0.08,y+0.08,side,side,C.lilac);
  box(s,x,y,side,side);
  const receipt=JSON.parse(fs.readFileSync(path.join(assetsRoot,"images",`${id}.json`),"utf8"));
  s.addImage({path:path.join(assetsRoot,"images",`${id}.png`),x:x+0.035,y:y+0.035,w:side-0.07,h:side-0.07,altText:receipt.altText});
}
function arrow(s,x,y,w=0.45,h=0.23,rotate=0) {
  s.addShape(pptx.ShapeType.rightArrow,{x,y,w,h,rotate,fill:{color:C.purple},line:{color:C.purple,transparency:100}});
}
function heading(s,item) {
  text(s,item.kicker,0.65,0.32,11.9,0.43,24,{color:C.purple,bold:true});
  text(s,item.title,0.65,0.87,12,1.36,38,{fontFace:"Aptos Display",bold:true});
}
const pilot=process.argv.includes("--pilot");
const selected=pilot?deck.slides.filter(s=>["S01","S05","S08","S09"].includes(s.id)):deck.slides;
for (const item of selected) {
  current=item;
  const s=pptx.addSlide();
  s.background={color:C.white};
  s.addNotes(notesFor(item));
  band(s,item.takeaway,0.65,6.52,12);
  if(item.layout!=="presenter") heading(s,item);
  switch(item.layout) {
    case "presenter":
      text(s,item.kicker,0.65,0.32,11.9,0.43,24,{bold:true,color:C.purple});
      text(s,item.title,0.65,1.05,8,2,46,{bold:true,fontFace:"Aptos Display"});
      text(s,"Custom Skills for\nGitHub Copilot Modernization",0.68,3.2,7.7,1.0,30,{bold:true,color:C.purple});
      band(s,"Bruno Capuano",0.68,4.68,5.4,C.lilac,C.ink);
      text(s,"One app. One skill. Five demos",0.68,5.45,7.6,0.6,27,{color:C.muted});
      box(s,9.02,1.12,3.55,4.88,C.lilac);
      s.addImage({path:headshot,x:8.92,y:1.02,w:3.55,h:4.88,sizing:{type:"crop",w:3.55,h:4.88},altText:"Bruno Capuano, presenter-supplied local photograph"});
      s.addShape(pptx.ShapeType.rect,{x:8.92,y:1.02,w:3.55,h:4.88,fill:{color:C.white,transparency:100},line:{color:C.ink,width:1.2}});
      break;
    case "migration":
      band(s,"BASELINE CAPTURE: NOT-RUN",0.72,2.38,6.7);
      text(s,"Newtonsoft.Json",0.94,3.17,6.2,0.65,34,{bold:true,align:"center"});
      arrow(s,3.8,4.03,0.48,0.28,90);
      text(s,"System.Text.Json",0.94,4.52,6.2,0.65,34,{bold:true,color:C.purple,align:"center"});
      text(s,"Working input\nInspect actual changes",0.94,5.28,6.2,0.97,26,{color:C.muted});
      art(s,item.image);
      break;
    case "knowledge":
      ["R1  Pricing exceptions","R2  JSON compatibility","R3  Approved audit path","R4  Safe diagnostics"].forEach((t,i)=>{
        text(s,t,0.85,2.65+i*0.82,6.65,0.59,29,{bold:true});
      });
      art(s,item.image);
      break;
    case "skill":
      box(s,0.72,2.44,6.75,1.42,C.pale);
      text(s,"SKILL.md",0.98,2.65,6.2,0.55,32,{bold:true});
      text(s,"name: northwind-modernization",0.98,3.22,6.2,0.48,24,{fontFace:"Consolas",color:C.purple});
      text(s,"When to apply it\nWorkflow and references\nWhat evidence to report",0.98,4.28,6.2,1.65,28,{color:C.muted});
      art(s,item.image);
      break;
    case "review-skill": {
      const rows=[
        ["Description","Relevant task and scope"],
        ["Requirements","Concrete rules and examples"],
        ["Workflow","Migration, repair or reuse"],
        ["Evidence","Real checks and limitations"]
      ];
      rows.forEach(([a,b],i)=>{
        const y=2.45+i*0.89;
        box(s,0.72,y,11.9,0.73,i%2?C.white:C.pale);
        text(s,a,0.97,y+0.09,3.8,0.55,29,{bold:true,color:C.purple});
        text(s,b,5.12,y+0.09,7.16,0.55,28);
      });
      break;
    }
    case "guided":
      band(s,"GUIDED CAPTURE: NOT-RUN",0.72,2.37,6.7);
      box(s,0.72,3.19,6.7,1.02);
      text(s,"18 matching input files",0.96,3.4,6.2,0.56,29,{bold:true});
      box(s,0.72,4.51,6.7,1.02,C.pale);
      text(s,"+ 4 reviewed skill files",0.96,4.72,6.2,0.56,29,{bold:true,color:C.purple});
      text(s,"Fresh conversation. Explicit request",0.96,5.73,6.2,0.49,24,{color:C.muted});
      ["Assess","Plan","Change","Review"].forEach((label,i)=>{
        const y=2.49+i*0.98;
        box(s,8.45,y,3.85,0.67,i%2?C.white:C.pale);
        text(s,label,8.66,y+0.08,3.43,0.51,28,{bold:true,align:"center"});
        if(i<3) arrow(s,10.24,y+0.76,0.27,0.15,90);
      });
      break;
    case "regression":
      box(s,0.72,2.46,5.55,3.5,C.pale);
      text(s,"THE CONTRACT",1.0,2.72,5.0,0.5,24,{bold:true,color:C.purple});
      text(s,'"review_note": null',1.0,3.62,5.0,0.75,28,{fontFace:"Consolas",bold:true});
      text(s,"Required field\nOptional value",1.0,4.78,5.0,0.88,26,{color:C.muted});
      box(s,6.75,2.46,5.55,3.5,C.pink);
      text(s,"THE TEACHING BUG",7.02,2.72,5.0,0.5,24,{bold:true,color:C.purple});
      text(s,"WhenWritingNull",7.02,3.62,5.0,0.75,29,{fontFace:"Consolas",bold:true});
      text(s,"Property disappears\nThe assertion catches it",7.02,4.78,5.0,0.88,26,{color:C.muted});
      break;
    case "red-green": {
      const cards=[
        ["Reproduce","Read the actual\nfailed assertion",C.pink],
        ["Repair","Restore null handling\nKeep the assertion",C.pale],
        ["Verify","Same test, then\nthe full suite",C.white]
      ];
      cards.forEach(([label,body,fill],i)=>{
        const x=0.72+i*4.12;
        box(s,x,2.6,3.65,2.75,fill);
        text(s,label,x+0.22,2.92,3.21,0.65,32,{bold:true,color:C.purple});
        text(s,body,x+0.22,3.92,3.21,1.04,25);
        if(i<2) arrow(s,x+3.74,3.79,0.29,0.19);
      });
      text(s,"Prepared red / green exercise, not agent-performance evidence",0.8,5.67,11.7,0.62,24,{color:C.muted});
      break;
    }
    case "reuse":
      box(s,0.72,2.51,5.5,1.18,C.pale);
      text(s,"Two existing responses",0.98,2.83,4.98,0.56,29,{bold:true});
      arrow(s,6.38,2.99,0.42,0.25);
      box(s,6.98,2.51,5.45,1.18);
      text(s,"One JSON array",7.24,2.83,4.93,0.56,29,{bold:true,color:C.purple});
      text(s,"Same output options\nSame per-item contract",0.98,4.2,5.12,1.28,30,{bold:true});
      text(s,"Order stays intact\nEmpty input: []\nNull input: reject",7.24,4.12,4.95,1.63,27,{fontFace:"Aptos"});
      text(s,"No changes to CLI, pricing or audit",0.98,5.8,11.3,0.5,24,{color:C.muted});
      break;
    case "context":
      [["Prompt","Immediate task"],["Instructions","Broad project conventions"],["Skill","Relevant workflow and resources"],["Tests","Observable behavior"]].forEach(([a,b],i)=>{
        const y=2.45+i*0.89;
        box(s,0.72,y,11.9,0.73,i===2?C.pale:C.white);
        text(s,a,0.97,y+0.09,3.5,0.55,29,{bold:true,color:C.purple});
        text(s,b,4.6,y+0.09,7.7,0.55,28);
      });
      break;
    case "loop":
      [
        [0.85,2.48,"Version + own","One accountable owner"],
        [7.05,2.48,"Review","Intent, examples, tests"],
        [7.05,4.59,"Reuse","Another small change"],
        [0.85,4.59,"Maintain","Learn from real failures"]
      ].forEach(([x,y,a,b],i)=>{
        box(s,x,y,5.4,1.38,i%2?C.white:C.pale);
        text(s,a,x+0.22,y+0.17,4.96,0.56,30,{bold:true});
        text(s,b,x+0.22,y+0.84,4.96,0.42,24,{color:C.muted});
      });
      arrow(s,6.42,3.06,0.42,0.23); arrow(s,9.53,4.07,0.44,0.24,90);
      arrow(s,6.42,5.17,0.42,0.23,180); arrow(s,3.33,4.07,0.44,0.24,270);
      break;
    case "resources":
      box(s,0.72,2.42,11.85,1.69,C.pale);
      text(s,"The complete local demo kit",0.99,2.67,11.3,0.58,30,{bold:true,hyperlink:{url:deck.repositoryUrl}});
      text(s,"github.com/elbruno/GitHubCopilotModernizationSamples",0.99,3.38,11.3,0.5,25,{color:C.purple,hyperlink:{url:deck.repositoryUrl}});
      text(s,"Official agent skills docs",0.99,4.65,8.7,0.6,30,{bold:true,hyperlink:{url:"https://docs.github.com/en/copilot/concepts/agents/about-agent-skills"}});
      text(s,"docs.github.com",0.99,5.37,8.7,0.5,26,{color:C.purple});
      text(s,"Q&A",9.55,4.62,2.8,1.12,56,{bold:true,color:C.purple,align:"center"});
      break;
    default: throw Error(`Unknown layout ${item.layout}`);
  }
}
const basename=pilot?"tribal-knowledge-to-code-v03-pilot":"tribal-knowledge-to-code-v03";
const output=path.join(here,`${basename}.pptx`);
if(fs.existsSync(output)){
  const history=path.join(here,"history");
  fs.mkdirSync(history,{recursive:true});
  const old=path.join(history,`${hash(output)}.pptx`);
  if(!fs.existsSync(old))fs.copyFileSync(output,old);
}
await pptx.writeFile({fileName:output});
const manifest={
  schemaVersion:1,version:"v03",builtUtc:new Date().toISOString(),node:process.version,pptxgenjs:pptx.version,
  pptxSha256:hash(output),slideCount:selected.length,geometry,
  slides:selected.map(s=>({id:s.id,title:s.title,notes:notesFor(s)})),
  images:assets.assets.filter(a=>selected.some(s=>s.image===a.id)),headshot:assets.headshot,
  sources:["slides/v03/content.mjs","slides/v03/generate.mjs","demos/v03/session.json",
    "slides/v02/asset-review.json",".github/skills/northwind-modernization/SKILL.md"]
    .map(file=>({file,sha256:hash(path.join(root,file))}))
};
fs.writeFileSync(path.join(here,pilot?"pilot-manifest.json":"build-manifest.json"),JSON.stringify(manifest,null,2)+"\n");
if(!pilot){
  fs.writeFileSync(path.join(here,"speaker-notes.md"),"# Speaker notes: v03\n\nDesigned 60-minute session with 42 demo minutes; not a timed human rehearsal.\n\n"+
    selected.map(s=>`## ${s.id}: ${s.title.replaceAll("\n"," ")}\n\n${notesFor(s)}\n`).join("\n"));
  fs.writeFileSync(path.join(here,"outline.md"),"# v03 slide landmarks\n\n| ID | Minutes | Topic | Segment |\n| --- | --- | --- | --- |\n"+
    selected.map(s=>`| ${s.id} | ${s.time} | ${s.title.replaceAll("\n"," ")} | ${s.segment} |`).join("\n")+"\n");
  fs.writeFileSync(path.join(root,"demos/v03/run-of-show.md"),"# v03 run of show\n\nGenerated from `session.json`. Designed timing, not measured human rehearsal.\n\n"+
    "| Minutes | Segment | Slides | Checkpoint | Exact prompt |\n| --- | --- | --- | --- | --- |\n"+
    session.segments.map(s=>`| ${s.start}-${s.end} | ${s.topic} | ${s.slides.join(", ")} | ${s.checkpoint??"-"} | ${s.prompt??"-"} |`).join("\n")+
    "\n\nFive demos: **42 minutes**. Intro/recap: **8 minutes**. Protected Q&A: **10 minutes**.\n\n"+
    "Do not wait on generation for more than 60-90 unproductive seconds. Disclose each prepared fallback. Actual Copilot runs remain not-run until genuinely captured.\n");
}
console.log(`Built ${selected.length} v03 slides: ${output}`);
