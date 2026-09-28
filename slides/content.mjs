export const deck = {
  title: "From Tribal Knowledge to Code: Custom Skills for GitHub Copilot Modernization",
  author: "Bruno Capuano",
  event: "September 29, 2026 | Microsoft Reactor",
  repositoryUrl: null,
  slides: [
    {
      id: "S01", time: "0-3", duration: "3 minutes including host introduction", layout: "hero",
      title: "From Tribal Knowledge\nto Code",
      subtitle: "Custom Skills for GitHub Copilot Modernization",
      takeaway: "Turn a repeated explanation into a reusable workflow",
      labels: ["Team knowledge", "Actionable skill", "Reviewable change"],
      points: [
        "Every team has someone who says: yes, that code works, but we do not do it that way here",
        "Today we turn one of those explanations into explicit guidance and observable checks",
        "This is a synthetic .NET dependency/API migration, not an Azure migration"
      ],
      show: "PowerPoint title slide; keep unrelated desktop windows off the shared screen",
      evidence: "The runnable reference and legacy sample are real; independent Copilot captures are not-run",
      transition: "Let us start with a question: it compiles, but is it right for us?",
      fallback: "If the host handoff runs long, keep this introduction to one sentence",
      source: "docs/product-notes.md"
    },
    {
      id: "S02", time: "3-5", duration: "2 minutes", layout: "three",
      title: "It compiles. Is it right for us?",
      takeaway: "A successful build answers only one question",
      labels: ["Technical\ncorrectness", "Business\ncorrectness", "Organizational\nfit"],
      points: [
        "Ask who has seen a successful build hide a business regression",
        "A partner quote for 33.35 times three should total 102.04, not just compile",
        "Show the rounding test early: the reference demonstrates a behavior, not agent superiority"
      ],
      show: "tests/Northwind.UnitTests/PricingTests.cs, midpoint case",
      evidence: "Concrete decimal rounding assertion and expected total 102.04",
      transition: "What are the explanations our team repeats when reviewing that change?",
      fallback: "Read the test from the file without starting a process",
      source: "tests/Northwind.UnitTests/PricingTests.cs"
    },
    {
      id: "S03", time: "5-7", duration: "2 minutes", layout: "four",
      title: "The rules that never made it\ninto the prompt",
      takeaway: "Existing source contains clues; the skill captures intent",
      labels: ["R1  Pricing exception", "R2  JSON contract", "R3  Audit convention", "R4  Safe diagnostics"],
      points: [
        "Introduce the fictional Northwind Outfitters Quote Service",
        "Partner discounts start at three; shipping follows the discounted net",
        "Consumers expect lowercase strings and an explicit null; logs must exclude customer data",
        "These behaviors are visible in the legacy source; the skill makes them discoverable and repeatable"
      ],
      show: "knowledge/team-notes.md beside the small source tree",
      evidence: "Synthetic notes map to R1-R4 in knowledge/rules-catalog.md",
      transition: "We do not need to paste everything into every prompt",
      fallback: "Use the four cards and tell one short fictional team story",
      source: "knowledge/team-notes.md"
    },
    {
      id: "S04", time: "7-11", duration: "4 minutes", layout: "four",
      title: "Put the right knowledge\nin the right place",
      takeaway: "Assess  >  Plan  >  Change  >  Review",
      labels: ["Prompt\nImmediate task", "Instructions\nProject conventions", "Skill\nSpecialized workflow", "Tests and CI\nExecutable checks"],
      points: [
        "A prompt states today's desired change",
        "Repository instructions describe conventions that apply broadly",
        "A skill packages a relevant workflow and supporting examples",
        "Tests define repeatable checks; people still decide whether the change is appropriate"
      ],
      show: ".github/copilot-instructions.md, then the skill directory",
      evidence: "Separate files with separate responsibilities; no domain-rule wall in general instructions",
      transition: "First, let us give the migration task without adding the specialized context",
      fallback: "Explain the distinction directly from this slide; no host feature depends on it",
      source: "https://docs.github.com/en/copilot/concepts/agents/about-agent-skills"
    },
    {
      id: "S05", time: "11-19", duration: "8 minutes", layout: "demo",
      title: "First pass: modernize the technology",
      takeaway: "Same behavior. Inspect the actual diff",
      labels: ["Newtonsoft.Json", "System.Text.Json"],
      badge: "Baseline capture: not-run",
      points: [
        "Open the isolated baseline root in a fresh app conversation, not this authoring repository",
        "Show the tiny working app, one request, and the exact prepared baseline prompt",
        "Review any real result fairly; a correct baseline is a valid outcome",
        "If no independent run exists, explicitly switch to the legacy/reference walkthrough"
      ],
      show: "Isolated baseline root; prompts/01-baseline.txt; src/Northwind.Quotes/QuoteJson.cs",
      evidence: "Input manifest and real output only; never call the reference a baseline capture",
      transition: "Now let us take one repeated explanation and make it actionable",
      fallback: "After 60-90 seconds, say: this is the prepared reference, not a captured Copilot run",
      source: "prompts/01-baseline.txt"
    },
    {
      id: "S06", time: "19-23", duration: "4 minutes", layout: "rule",
      title: "Turn one rule into actionable guidance",
      takeaway: "When it applies + what to preserve + example + evidence",
      labels: ["Keep the optional field", "\"review_note\": null"],
      points: [
        "Start with the fictional integration note: an absent review note still has a property",
        "Explain the difference between a preference and an observable contract",
        "Show the real serializer setting and the acceptance assertion",
        "Give one bad counterexample: ignoring nulls can silently change the response shape"
      ],
      show: "src/Northwind.Quotes/QuoteJson.cs and tests/Northwind.AcceptanceTests/ContractTests.cs",
      evidence: "Actual JsonIgnoreCondition.Never source excerpt; explicit null assertion",
      transition: "That rule is useful; the surrounding workflow makes it reusable",
      fallback: "The slide's source excerpt is copied directly by the generator",
      source: "src/Northwind.Quotes/QuoteJson.cs"
    },
    {
      id: "S07", time: "23-27", duration: "4 minutes", layout: "skill",
      title: "A skill is more than a long prompt",
      takeaway: "Guidance, not guaranteed enforcement",
      labels: ["SKILL.md", "Supporting references", "Workflow + review criteria"],
      points: [
        "Show the actual name and task-specific activation description",
        "The supporting references stay inside the skill package so exported links work",
        "Official docs describe relevance-based loading; this does not guarantee correct application",
        "The general app agent is the prepared route; dedicated Upgrade integration is unverified here"
      ],
      show: ".github/skills/northwind-modernization/SKILL.md and references/review-checklist.md",
      evidence: "Installed CLI skill inventory detects the project skill; that is not per-run activation telemetry",
      transition: "Now start again from the same input, with the skill supplied",
      fallback: "Open the files directly and disclose any explicit request to use the skill",
      source: ".github/skills/northwind-modernization/SKILL.md"
    },
    {
      id: "S08", time: "27-41", duration: "14 minutes", layout: "demo",
      title: "Same task. Explicit organizational context",
      takeaway: "Matching source hashes. Additional skill context",
      labels: ["Same legacy input", "Skill-guided request"],
      badge: "Guided capture: not-run",
      points: [
        "Open the separately exported guided root in a fresh conversation",
        "Show matching starting source/test manifests and the four added skill files",
        "Paste the exact guided prompt and inspect available evidence of skill use without inventing logs",
        "Evaluate both results with the same external criteria; preserve failures and interventions"
      ],
      show: "Guided root; prompts/02-guided.txt; external scripts/compare.ps1",
      evidence: "Identical starting source, smoke tests and prompt core; different supplied context",
      transition: "Let us compare evidence rather than impressions",
      fallback: "Use the reference walkthrough with unit/acceptance tests; say no independent guided output was captured",
      source: "scripts/export-demo.ps1"
    },
    {
      id: "S09", time: "41-44", duration: "3 minutes", layout: "checklist",
      title: "What we will compare",
      takeaway: "No captured runs. No declared winner",
      labels: ["Migration + build", "Pricing + wire contract", "Audit + diagnostics", "Diff scope + review"],
      points: [
        "Both independent capture manifests currently say not-run",
        "Show the real not-run report rather than a placeholder success table",
        "The reference passes defined checks but is not evidence of generated-agent performance",
        "If both future candidates pass, show that; if guided fails, preserve and diagnose it"
      ],
      show: "demos/captures/baseline.json, guided.json; actual comparison.md",
      evidence: "Four allowed statuses: pass, fail, not-run, blocked; finite checks are not a compliance guarantee",
      transition: "The reusable asset is not a winning screenshot; it is a shared team practice",
      fallback: "Keep the checklist and explicitly say the independent experiment has not run",
      source: "scripts/compare.ps1"
    },
    {
      id: "S10", time: "44-47", duration: "3 minutes", layout: "flow",
      title: "From one developer to team practice",
      takeaway: "Skills guide. Tests check. People decide",
      labels: ["Version", "Review", "Own", "Reuse", "Maintain"],
      points: [
        "Put the skill and examples under source control with the code they guide",
        "Assign an owner and update examples when the contract changes",
        "Review skills as executable-workflow guidance, including scripts and tool permissions",
        "The optional reuse prompt is a stretch exercise, not a second application"
      ],
      show: "docs/maintenance.md; optionally prompts/04-reuse.txt without executing it",
      evidence: "Rule-to-test ownership and change checklist, not promised deterministic generation",
      transition: "You can start much smaller than a complete company standards catalog",
      fallback: "Cut the optional reuse explanation if time is short",
      source: "docs/maintenance.md"
    },
    {
      id: "S11", time: "47-50", duration: "3 minutes", layout: "flow",
      title: "Your first skill starts with\none repeated explanation",
      takeaway: "Pick one task. Capture one rule. Review the result",
      labels: ["Pick", "Capture", "Example", "Review", "Reuse"],
      points: [
        "Choose one modernization task you already understand",
        "Write down the rule you explain every code review",
        "Add a good example, a counterexample, and evidence that would convince a reviewer",
        "Reuse it on another small change and refine it from actual failures"
      ],
      show: "Skill reference checklist; keep focus on the attendee's first next action",
      evidence: "One actionable rule can be checked; a vague paragraph cannot",
      transition: "Here are the resources and the three things I hope you take away",
      fallback: "Give the closing action verbatim and move to resources",
      source: ".github/skills/northwind-modernization/references/review-checklist.md"
    },
    {
      id: "S12", time: "50-52", duration: "2 minutes, then keep visible for Q&A until minute 60", layout: "resources",
      title: "Try the workflow",
      takeaway: "Make knowledge explicit. Check behavior. Reuse what works",
      labels: ["Sample repository link pending", "Official agent skills docs", "Official upgrade docs"],
      points: [
        "The attendee repository is staged locally; its public URL must be verified before delivery",
        "Official skills and upgrade documentation are linked in the notes and resources file",
        "Close: pick one modernization task, capture one repeated rule, encode it in a skill, review, reuse",
        "Keep this slide visible for Q&A; do not claim public availability until it is verified"
      ],
      show: "docs/resources.md; Q&A answers in demos/runbook.md",
      evidence: "Verified official links; no fabricated sample URL or QR code",
      transition: "What is one rule your team keeps explaining?",
      fallback: "Direct attendees to the official docs; say the sample link will be supplied after access is verified",
      source: "https://docs.github.com/en/copilot/concepts/agents/about-agent-skills"
    }
  ]
};

export function notesFor(slide) {
  return [
    `${slide.id} | elapsed ${slide.time} minutes | Target: ${slide.duration}`,
    "All application people, data, rules, and the audit component are synthetic.",
    ...slide.points.map(point => `- ${point}`),
    `Show: ${slide.show}`,
    `Evidence: ${slide.evidence}`,
    `Transition: ${slide.transition}`,
    `Fallback: ${slide.fallback}`,
    `Source: ${slide.source}`,
    ...(slide.id === "S12" ? [
      "https://docs.github.com/en/copilot/concepts/agents/about-agent-skills",
      "https://learn.microsoft.com/en-us/dotnet/core/porting/github-copilot-upgrade/overview"
    ] : [])
  ].join("\n");
}
