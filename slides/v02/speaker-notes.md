# Speaker notes: v02 draft

Generated from v02/content.mjs. Original v01 notes are preserved. Designed timing, not a measured rehearsal.

## S01: From Tribal Knowledge to Code

S01 | elapsed 0-3 minutes | Target: 3 minutes including host introduction
All application people, data, rules, and the audit component are synthetic.
- Every team has someone who says: yes, that code works, but we do not do it that way here
- Today we turn one of those explanations into explicit guidance and observable checks
- This is a synthetic .NET dependency/API migration, not an Azure migration
Show: PowerPoint title slide; keep unrelated desktop windows off the shared screen
Evidence: The runnable reference and legacy sample are real; independent Copilot captures are not-run
Transition: Let us start with a question: it compiles, but is it right for us?
Fallback: If the host handoff runs long, keep this introduction to one sentence
Source: docs/product-notes.md
Visual revision: v02 draft. Flare conceptual illustrations are not screenshots, run evidence, or official product artwork.
The presenter supplied the headshot for this introduction; it was embedded locally without image-service upload.
The v01 content, original slide files and original notes are preserved separately. Sunburst final-image generation has not happened.

## S02: It compiles. Is it right for us?

S02 | elapsed 3-5 minutes | Target: 2 minutes
All application people, data, rules, and the audit component are synthetic.
- Ask who has seen a successful build hide a business regression
- A partner quote for 33.35 times three should total 102.04, not just compile
- Show the rounding test early: the reference demonstrates a behavior, not agent superiority
Show: tests/Northwind.UnitTests/PricingTests.cs, midpoint case
Evidence: Concrete decimal rounding assertion and expected total 102.04
Transition: What are the explanations our team repeats when reviewing that change?
Fallback: Read the test from the file without starting a process
Source: tests/Northwind.UnitTests/PricingTests.cs
Visual revision: v02 draft. Flare conceptual illustrations are not screenshots, run evidence, or official product artwork.
The v01 content, original slide files and original notes are preserved separately. Sunburst final-image generation has not happened.

## S03: The rules outside the prompt

S03 | elapsed 5-7 minutes | Target: 2 minutes
All application people, data, rules, and the audit component are synthetic.
- Introduce the fictional Northwind Outfitters Quote Service
- Partner discounts start at three; shipping follows the discounted net
- Consumers expect lowercase strings and an explicit null; logs must exclude customer data
- These behaviors are visible in the legacy source; the skill makes them discoverable and repeatable
Show: knowledge/team-notes.md beside the small source tree
Evidence: Synthetic notes map to R1-R4 in knowledge/rules-catalog.md
Transition: We do not need to paste everything into every prompt
Fallback: Use the four cards and tell one short fictional team story
Source: knowledge/team-notes.md
Visual revision: v02 draft. Flare conceptual illustrations are not screenshots, run evidence, or official product artwork.
The v01 content, original slide files and original notes are preserved separately. Sunburst final-image generation has not happened.

## S04: Put knowledge where it belongs

S04 | elapsed 7-11 minutes | Target: 4 minutes
All application people, data, rules, and the audit component are synthetic.
- A prompt states today's desired change
- Repository instructions describe conventions that apply broadly
- A skill packages a relevant workflow and supporting examples
- Tests define repeatable checks; people still decide whether the change is appropriate
Show: .github/copilot-instructions.md, then the skill directory
Evidence: Separate files with separate responsibilities; no domain-rule wall in general instructions
Transition: First, let us give the migration task without adding the specialized context
Fallback: Explain the distinction directly from this slide; no host feature depends on it
Source: https://docs.github.com/en/copilot/concepts/agents/about-agent-skills
Visual revision: v02 draft. Flare conceptual illustrations are not screenshots, run evidence, or official product artwork.
The v01 content, original slide files and original notes are preserved separately. Sunburst final-image generation has not happened.

## S05: Modernize the library, not the business rules

S05 | elapsed 11-19 minutes | Target: 8 minutes
All application people, data, rules, and the audit component are synthetic.
- Open the isolated baseline root in a fresh app conversation, not this authoring repository
- Show the tiny working app, one request, and the exact prepared baseline prompt
- Review any real result fairly; a correct baseline is a valid outcome
- If no independent run exists, explicitly switch to the legacy/reference walkthrough
Show: Isolated baseline root; prompts/01-baseline.txt; src/Northwind.Quotes/QuoteJson.cs
Evidence: Input manifest and real output only; never call the reference a baseline capture
Transition: Now let us take one repeated explanation and make it actionable
Fallback: After 60-90 seconds, say: this is the prepared reference, not a captured Copilot run
Source: prompts/01-baseline.txt
Visual revision: v02 draft. Flare conceptual illustrations are not screenshots, run evidence, or official product artwork.
The v01 content, original slide files and original notes are preserved separately. Sunburst final-image generation has not happened.

## S06: Make one rule actionable

S06 | elapsed 19-23 minutes | Target: 4 minutes
All application people, data, rules, and the audit component are synthetic.
- Start with the fictional integration note: an absent review note still has a property
- Explain the difference between a preference and an observable contract
- Show the real serializer setting and the acceptance assertion
- Give one bad counterexample: ignoring nulls can silently change the response shape
Show: src/Northwind.Quotes/QuoteJson.cs and tests/Northwind.AcceptanceTests/ContractTests.cs
Evidence: Actual JsonIgnoreCondition.Never source excerpt; explicit null assertion
Transition: That rule is useful; the surrounding workflow makes it reusable
Fallback: The slide's source excerpt is copied directly by the generator
Source: src/Northwind.Quotes/QuoteJson.cs
Visual revision: v02 draft. Flare conceptual illustrations are not screenshots, run evidence, or official product artwork.
The v01 content, original slide files and original notes are preserved separately. Sunburst final-image generation has not happened.

## S07: Package the know-how

S07 | elapsed 23-27 minutes | Target: 4 minutes
All application people, data, rules, and the audit component are synthetic.
- Show the actual name and task-specific activation description
- The supporting references stay inside the skill package so exported links work
- Official docs describe relevance-based loading; this does not guarantee correct application
- The general app agent is the prepared route; dedicated Upgrade integration is unverified here
Show: .github/skills/northwind-modernization/SKILL.md and references/review-checklist.md
Evidence: Installed CLI skill inventory detects the project skill; that is not per-run activation telemetry
Transition: Now start again from the same input, with the skill supplied
Fallback: Open the files directly and disclose any explicit request to use the skill
Source: .github/skills/northwind-modernization/SKILL.md
Visual revision: v02 draft. Flare conceptual illustrations are not screenshots, run evidence, or official product artwork.
The v01 content, original slide files and original notes are preserved separately. Sunburst final-image generation has not happened.

## S08: Same task. Explicit team context

S08 | elapsed 27-41 minutes | Target: 14 minutes
All application people, data, rules, and the audit component are synthetic.
- Open the separately exported guided root in a fresh conversation
- Show matching starting source/test manifests and the four added skill files
- Paste the exact guided prompt and inspect available evidence of skill use without inventing logs
- Evaluate both results with the same external criteria; preserve failures and interventions
Show: Guided root; prompts/02-guided.txt; external scripts/compare.ps1
Evidence: Identical starting source, smoke tests and prompt core; different supplied context
Transition: Let us compare evidence rather than impressions
Fallback: Use the reference walkthrough with unit/acceptance tests; say no independent guided output was captured
Source: scripts/export-demo.ps1
Visual revision: v02 draft. Flare conceptual illustrations are not screenshots, run evidence, or official product artwork.
The v01 content, original slide files and original notes are preserved separately. Sunburst final-image generation has not happened.

## S09: Compare evidence, not impressions

S09 | elapsed 41-44 minutes | Target: 3 minutes
All application people, data, rules, and the audit component are synthetic.
- Both independent capture manifests currently say not-run
- Show the real not-run report rather than a placeholder success table
- The reference passes defined checks but is not evidence of generated-agent performance
- If both future candidates pass, show that; if guided fails, preserve and diagnose it
Show: demos/captures/baseline.json, guided.json; actual comparison.md
Evidence: Four allowed statuses: pass, fail, not-run, blocked; finite checks are not a compliance guarantee
Transition: The reusable asset is not a winning screenshot; it is a shared team practice
Fallback: Keep the checklist and explicitly say the independent experiment has not run
Source: scripts/compare.ps1
Visual revision: v02 draft. Flare conceptual illustrations are not screenshots, run evidence, or official product artwork.
The v01 content, original slide files and original notes are preserved separately. Sunburst final-image generation has not happened.

## S10: Make it a team practice

S10 | elapsed 44-47 minutes | Target: 3 minutes
All application people, data, rules, and the audit component are synthetic.
- Put the skill and examples under source control with the code they guide
- Assign an owner and update examples when the contract changes
- Review skills as executable-workflow guidance, including scripts and tool permissions
- The optional reuse prompt is a stretch exercise, not a second application
Show: docs/maintenance.md; optionally prompts/04-reuse.txt without executing it
Evidence: Rule-to-test ownership and change checklist, not promised deterministic generation
Transition: You can start much smaller than a complete company standards catalog
Fallback: Cut the optional reuse explanation if time is short
Source: docs/maintenance.md
Visual revision: v02 draft. Flare conceptual illustrations are not screenshots, run evidence, or official product artwork.
The v01 content, original slide files and original notes are preserved separately. Sunburst final-image generation has not happened.

## S11: Start with one repeated explanation

S11 | elapsed 47-50 minutes | Target: 3 minutes
All application people, data, rules, and the audit component are synthetic.
- Choose one modernization task you already understand
- Write down the rule you explain every code review
- Add a good example, a counterexample, and evidence that would convince a reviewer
- Reuse it on another small change and refine it from actual failures
Show: Skill reference checklist; keep focus on the attendee's first next action
Evidence: One actionable rule can be checked; a vague paragraph cannot
Transition: Here are the resources and the three things I hope you take away
Fallback: Give the closing action verbatim and move to resources
Source: .github/skills/northwind-modernization/references/review-checklist.md
Visual revision: v02 draft. Flare conceptual illustrations are not screenshots, run evidence, or official product artwork.
The v01 content, original slide files and original notes are preserved separately. Sunburst final-image generation has not happened.

## S12: Try the workflow

S12 | elapsed 50-52 minutes | Target: 2 minutes, then keep visible for Q&A until minute 60
All application people, data, rules, and the audit component are synthetic.
- The attendee repository is staged locally; its public URL must be verified before delivery
- Official skills and upgrade documentation are linked in the notes and resources file
- Close: pick one modernization task, capture one repeated rule, encode it in a skill, review, reuse
- Keep this slide visible for Q&A; do not claim public availability until it is verified
Show: docs/resources.md; Q&A answers in demos/runbook.md
Evidence: Verified official links; no fabricated sample URL or QR code
Transition: What is one rule your team keeps explaining?
Fallback: Direct attendees to the official docs; say the sample link will be supplied after access is verified
Source: https://docs.github.com/en/copilot/concepts/agents/about-agent-skills
https://docs.github.com/en/copilot/concepts/agents/about-agent-skills
https://learn.microsoft.com/en-us/dotnet/core/porting/github-copilot-upgrade/overview
Visual revision: v02 draft. Flare conceptual illustrations are not screenshots, run evidence, or official product artwork.
The v01 content, original slide files and original notes are preserved separately. Sunburst final-image generation has not happened.
