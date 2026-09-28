import fs from "node:fs";
import { fileURLToPath } from "node:url";

export const session = JSON.parse(fs.readFileSync(fileURLToPath(new URL("../../demos/v03/session.json", import.meta.url)), "utf8"));
export const deck = {
  title: session.title,
  author: "Bruno Capuano",
  version: "v03",
  repositoryUrl: "https://github.com/elbruno/GitHubCopilotModernizationSamples",
  slides: [
    {
      id: "S01", segment: "intro", time: "0-3", layout: "presenter",
      kicker: "CUSTOM SKILLS / FIVE LIVE DEMOS",
      title: "From Tribal Knowledge\nto Code",
      takeaway: "Create a skill. Apply it. Test its limits. Reuse it",
      points: [
        "Introduce yourself and the recurring explanation: it works, but we do not do it that way here",
        "One synthetic .NET app, one reusable skill and five demos; slides are bookmarks, not the main event",
        "The app is local; independent Copilot generation needs an enabled account and network",
        "Prepared checkpoints and reference tests are real, but are not independent agent captures"
      ],
      show: "Title, local presenter photo, then the small app tree",
      evidence: "Seven labeled teaching checkpoints; generation status remains not-run",
      transition: "First, state only the technology change",
      fallback: "Keep the introduction to one minute if the host handoff runs long",
      source: "demos/v03/session.json"
    },
    {
      id: "S02", segment: "demo-1", time: "3-8", layout: "migration",
      kicker: "DEMO 1 / TRY THE TASK",
      title: "Modernize the library,\nkeep the behavior",
      takeaway: "A correct baseline is a valid result",
      image: "careful-migration",
      points: [
        "Open 01-baseline alone in a fresh conversation and run its smoke tests and partner request",
        "Point out total 270, explicit null and the separate audit event; the starting app works",
        "Explain the midpoint example: 100.05 subtotal minus 10.01 discount plus 12 shipping equals 102.04",
        "Paste prompts/01-baseline.txt exactly; inspect actual changes without presuming a failure",
        "At minute 8 move on; do not spend the session waiting on one generation"
      ],
      show: "01-baseline source, real terminal output and the exact baseline prompt",
      evidence: "Legacy behavior is already correct; only real generated output can count as an agent result",
      transition: "Now package the team's intent rather than repeating it in every prompt",
      fallback: "After 60-90 seconds of unproductive waiting, show 04-reference and identify it as prepared",
      source: "prompts/01-baseline.txt"
    },
    {
      id: "S03", segment: "demo-2", time: "8-10", layout: "knowledge",
      kicker: "DEMO 2 / SYNTHETIC TEAM KNOWLEDGE",
      title: "Start with the explanations\nyour team repeats",
      takeaway: "Real requirements need examples and observable checks",
      image: "knowledge-transfer",
      points: [
        "Switch to 02-author-skill, which has legacy code and synthetic team notes but no prewritten project skill",
        "Highlight pricing exceptions, wire compatibility, audit conventions and safe diagnostics",
        "The source already contains clues; the task is to make intent discoverable, not invent policy",
        "Use demos/v03/prompts/02-author-skill.txt to ask Copilot to author guidance only, not change application code"
      ],
      show: "knowledge/team-notes.md beside the small source tree",
      evidence: "Four synthetic requirements mapped to R1-R4",
      transition: "Give this knowledge a portable home",
      fallback: "Read one null-field note aloud and use the prepared skill to explain its translation",
      source: "knowledge/team-notes.md"
    },
    {
      id: "S04", segment: "demo-2", time: "10-14", layout: "skill",
      kicker: "DEMO 2 / AUTHOR THE SKILL",
      title: "Build a reusable package",
      takeaway: "Keep the workflow focused and its references portable",
      image: "skill-toolkit",
      points: [
        "Show the actual skill Copilot created, or explicitly switch to the prepared version",
        "Explain name and task-specific description, then inspect-first steps and concrete examples",
        "Keep references inside the skill directory so the exported package has no broken links",
        "Reject broad tool permissions, invented requirements and unrelated implementation changes"
      ],
      show: ".github/skills/northwind-modernization/SKILL.md and its references directory",
      evidence: "Documented repository skill structure; the package has four files",
      transition: "Before using generated guidance, review it like code",
      fallback: "Open the reviewed skill in 03-guided; call it prepared and explain one rule live",
      source: "https://docs.github.com/en/copilot/concepts/agents/about-agent-skills"
    },
    {
      id: "S05", segment: "demo-2", time: "14-18", layout: "review-skill",
      kicker: "DEMO 2 / REVIEW BEFORE REUSE",
      title: "When should it apply?\nWhat would convince us?",
      takeaway: "A description supports selection, not guaranteed adherence",
      points: [
        "Check that the description covers migration, contract repair and small serialization reuse",
        "Inspect an actionable R2 rule: explicit null property, good and bad examples, unchanged assertion",
        "Review migration versus repair versus reuse branches so unrelated tasks do not trigger dependency changes",
        "Announce the prepared reviewed skill handoff into 03-guided instead of silently substituting files",
        "A live-authored variation is fine for teaching, but is not the predefined comparison input"
      ],
      show: "Skill frontmatter, concrete traps, workflow branches and review checklist",
      evidence: "Skill text and real tests, not claims about hidden activation telemetry",
      transition: "Start again with the same input and explicit team context",
      fallback: "Use the prepared checklist and stop the skill-authoring segment at minute 18",
      source: ".github/skills/northwind-modernization/SKILL.md"
    },
    {
      id: "S06", segment: "demo-3", time: "18-30", layout: "guided",
      kicker: "DEMO 3 / APPLY THE SKILL",
      title: "Same task.\nExplicit team context",
      takeaway: "Inspect the real diff and run the same checks",
      points: [
        "Use 03-guided as its own project and a fresh conversation, never the parent folder",
        "Show the 18 matching legacy source/test files and four added skill files",
        "Paste prompts/02-guided.txt; it explicitly requests the skill",
        "Show only activation or file-access evidence the host actually exposes; availability alone is not use",
        "Run visible tests and external evaluation if there is a completed candidate",
        "Do not replace a candidate with the reference and call it generated output"
      ],
      show: "Guided prompt, skill, real diff, test output and scripts/evaluate.ps1",
      evidence: "Baseline and guided independent captures are currently not-run; no claimed winner",
      transition: "A good skill still needs a way to catch mistakes",
      fallback: "Run real tests in 04-reference and label it authored reference; move on at minute 30",
      source: "prompts/02-guided.txt"
    },
    {
      id: "S07", segment: "demo-4", time: "30-32", layout: "regression",
      kicker: "DEMO 4 / INTRODUCE A TEACHING BUG",
      title: "One option.\nA broken contract",
      takeaway: "Deliberately introduced, not a captured Copilot mistake",
      points: [
        "Disclose the intentional regression before showing the red test",
        "Open 05-null-regression and show WhenWritingNull in the serializer options",
        "Run SerializationTests.PreservesExplicitNull with a build of current code",
        "Read the real assertion about review_note existing even when its value is null"
      ],
      show: "Faulted setting and unchanged null-contract test",
      evidence: "Scripted rehearsal observes the exact intended assertion, not an arbitrary nonzero exit",
      transition: "Use the skill to explain and repair the mismatch",
      fallback: "The broken checkpoint is already prepared; do not break the source repository",
      source: "tests/Northwind.UnitTests/SerializationTests.cs"
    },
    {
      id: "S08", segment: "demo-4", time: "32-37", layout: "red-green",
      kicker: "DEMO 4 / REPAIR AND VERIFY",
      title: "Keep the test.\nRepair the implementation",
      takeaway: "Skills carry intent. Tests detect defined regressions",
      points: [
        "Paste demos/v03/prompts/04-repair.txt and require reproduction before changes",
        "Reject removing or weakening the assertion as a fix",
        "After the minimal repair, run the exact same focused test and then the full suite",
        "If using set-demo-null-rule.ps1, disclose the scripted repair rather than calling it agent-generated",
        "These finite checks do not guarantee universal compliance"
      ],
      show: "Focused failure, serializer repair, same test passing and full-suite result",
      evidence: "Actual prepared-fixture red/green rehearsal; no fabricated agent run",
      transition: "Can the same skill help with a different task?",
      fallback: "Use the guarded scripted repair and show real tests; hard stop at minute 37",
      source: "scripts/set-demo-null-rule.ps1"
    },
    {
      id: "S09", segment: "demo-5", time: "37-45", layout: "reuse",
      kicker: "DEMO 5 / REUSE THE KNOWLEDGE",
      title: "A new task.\nThe same contract",
      takeaway: "Reuse output options, not another wall of instructions",
      points: [
        "Start a fresh conversation in 06-reuse-start and paste demos/v03/prompts/05-reuse.txt",
        "Add WriteBatch for existing responses without changing CLI, pricing, audit or dependencies",
        "Preserve item order, field names, string enums, numeric money and explicit null",
        "Check empty input produces an array and a null collection throws",
        "Check actual executed test counts; a filter matching zero tests is not success",
        "Prepared 07-reuse-complete has three focused tests and the full contract suite"
      ],
      show: "Small batch method and focused per-item equivalence tests",
      evidence: "Existing CLI, domain and audit source stay hash-identical in the prepared reuse checkpoint",
      transition: "Name the pieces you just watched work together",
      fallback: "At the cutoff, switch to 07-reuse-complete, disclose it and run its real tests",
      source: "demos/v03/prompts/05-reuse.txt"
    },
    {
      id: "S10", segment: "recap", time: "45-47", layout: "context",
      kicker: "RECAP / WHAT YOU JUST USED",
      title: "Four tools, different jobs",
      takeaway: "Context guides the work; evidence supports the review",
      points: [
        "The prompt stated the immediate task",
        "Instructions supplied broad project conventions",
        "The skill supplied a relevant workflow, examples and resources",
        "Tests checked observable cases; a person still reviewed scope and intent",
        "Keep this recap short: attendees have already seen the distinctions live"
      ],
      show: "Prompt, instructions, skill package and test files as concrete examples",
      evidence: "Different files with distinct responsibilities",
      transition: "Make the skill a maintained team asset",
      fallback: "Give the four definitions in one sentence and protect Q&A",
      source: "https://docs.github.com/en/copilot/concepts/agents/about-agent-skills"
    },
    {
      id: "S11", segment: "recap", time: "47-50", layout: "loop",
      kicker: "YOUR NEXT STEP / ONE REPEATED EXPLANATION",
      title: "Make it a team practice",
      takeaway: "Pick one task. Capture one rule. Check it. Reuse it",
      points: [
        "Version the skill with the code, give it an owner and review changes",
        "Update examples and tests when the business contract changes",
        "Start with a narrow task rather than a company-wide standards catalog",
        "Close with one repeated explanation the attendee can encode tomorrow"
      ],
      show: "Editable ownership/review/reuse/maintenance loop",
      evidence: "Maintenance checklist rather than a promise of deterministic generation",
      transition: "Here is the complete kit; what would your first skill capture?",
      fallback: "Close in one minute if needed; reach resources at minute 50",
      source: "docs/maintenance.md"
    },
    {
      id: "S12", segment: "questions", time: "50-60", layout: "resources",
      kicker: "RESOURCES / Q&A",
      title: "Try the five-demo workflow",
      takeaway: "Create a skill. Apply it. Test its limits. Reuse it",
      points: [
        "Keep the public sample and official documentation visible for the protected ten-minute Q&A",
        "The repository includes seven local checkpoints, exact prompts, real tests, notes and fallbacks",
        "Publication must be verified independently of generation and deck QA",
        "A correct baseline or imperfect guided run is legitimate; no forced success story",
        "Human rehearsal and actual independent agent captures remain separate pending activities"
      ],
      show: "Public sample URL and official agent-skills link",
      evidence: "Use the publication receipt and signed-out access check, not a guessed URL",
      transition: "What is one rule your team keeps explaining?",
      fallback: "If audience access fails, share official docs and resolve sample access after the session",
      source: "https://docs.github.com/en/copilot/concepts/agents/about-agent-skills"
    }
  ]
};

export function notesFor(slide) {
  const segment = session.segments.find(s => s.id === slide.segment);
  return [
    `${slide.id} | elapsed ${slide.time} minutes | ${segment.topic}`,
    "Designed timing, not a measured human rehearsal. All application data, people and policies are synthetic.",
    ...slide.points.map(point => `- ${point}`),
    `Show: ${slide.show}`,
    ...(segment.checkpoint ? [`Checkpoint: ${segment.checkpoint}`, `Exact prompt: ${segment.prompt}`] : []),
    `Evidence: ${slide.evidence}`, `Transition: ${slide.transition}`,
    `Fallback: ${slide.fallback}`, `Source: ${slide.source}`,
    "Presenter commands and spoken cues: demos/v03/runbook.md and demos/v03/demo-script.md",
    "Visuals: original conceptual Flare illustrations, not screenshots, agent evidence or official product artwork. Presenter supplied the local headshot; it was not uploaded for generation.",
    ...(slide.id === "S12" ? [deck.repositoryUrl, "https://docs.github.com/en/copilot/concepts/agents/about-agent-skills"] : [])
  ].join("\n");
}
