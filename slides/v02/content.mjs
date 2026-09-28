import { deck as original, notesFor as originalNotes } from "../content.mjs";

export const deck = structuredClone(original);
deck.version = "v02-draft";
deck.visualDirection = "White, deep purple ink, lilac panels, original conceptual Flare illustrations";

const changes = [
  {
    title: "From Tribal Knowledge\nto Code",
    kicker: "CUSTOM SKILLS / GITHUB COPILOT",
    takeaway: "Turn team knowledge into a reviewable change",
    layout: "presenter"
  },
  {
    title: "It compiles.\nIs it right for us?",
    kicker: "THE REAL QUESTION",
    takeaway: "A build is a starting point, not the whole review",
    layout: "proof"
  },
  {
    title: "The rules outside the prompt",
    kicker: "A FICTIONAL TEAM / A REAL PATTERN",
    takeaway: "The source contains clues. The skill captures intent",
    layout: "knowledge",
    image: "knowledge-transfer"
  },
  {
    title: "Put knowledge where it belongs",
    kicker: "FOUR TOOLS / DIFFERENT JOBS",
    takeaway: "Use the right context, then check the result",
    layout: "context-map"
  },
  {
    title: "Modernize the library,\nnot the business rules",
    kicker: "DEMO / FIRST PASS",
    takeaway: "Inspect the actual diff, whether it succeeds or fails",
    layout: "baseline",
    image: "careful-migration"
  },
  {
    title: "Make one rule actionable",
    kicker: "FROM TEAM NOTE TO ACCEPTANCE CRITERION",
    takeaway: "Preserve the contract, not the serializer defaults",
    layout: "rule"
  },
  {
    title: "Package the know-how",
    kicker: "THE REUSABLE SKILL",
    takeaway: "Guidance and resources, not guaranteed enforcement",
    layout: "skill",
    image: "skill-toolkit"
  },
  {
    title: "Same task.\nExplicit team context",
    kicker: "DEMO / GUIDED PASS",
    takeaway: "Change the supplied context, not the starting code",
    layout: "guided"
  },
  {
    title: "Compare evidence,\nnot impressions",
    kicker: "WHAT WE WILL CHECK",
    takeaway: "No captured runs. No declared winner",
    layout: "evidence",
    image: "evidence-review"
  },
  {
    title: "Make it a team practice",
    kicker: "THE MAINTENANCE LOOP",
    takeaway: "Skills guide. Tests check. People decide",
    layout: "loop"
  },
  {
    title: "Start with one\nrepeated explanation",
    kicker: "YOUR FIRST SKILL",
    takeaway: "Pick one task. Capture one rule. Review. Reuse",
    layout: "action",
    image: "knowledge-transfer"
  },
  {
    title: "Try the workflow",
    kicker: "RESOURCES / Q&A",
    takeaway: "Make knowledge explicit. Check behavior. Reuse what works",
    layout: "resources"
  }
];
deck.slides = deck.slides.map((slide, index) => ({ ...slide, ...changes[index] }));

export function notesFor(slide) {
  const base = originalNotes(slide);
  return base + [
    "",
    "Visual revision: v02 draft. Flare conceptual illustrations are not screenshots, run evidence, or official product artwork.",
    ...(slide.id === "S01" ? ["The presenter supplied the headshot for this introduction; it was embedded locally without image-service upload."] : []),
    "The v01 content, original slide files and original notes are preserved separately. Sunburst final-image generation has not happened."
  ].join("\n");
}
