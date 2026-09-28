# Speaker notes: v03

Designed 60-minute session with 42 demo minutes; not a timed human rehearsal.

## S01: From Tribal Knowledge to Code

S01 | elapsed 0-3 minutes | Set the challenge
Designed timing, not a measured human rehearsal. All application data, people and policies are synthetic.
- Introduce yourself and the recurring explanation: it works, but we do not do it that way here
- One synthetic .NET app, one reusable skill and five demos; slides are bookmarks, not the main event
- The app is local; independent Copilot generation needs an enabled account and network
- Prepared checkpoints and reference tests are real, but are not independent agent captures
Show: Title, local presenter photo, then the small app tree
Evidence: Seven labeled teaching checkpoints; generation status remains not-run
Transition: First, state only the technology change
Fallback: Keep the introduction to one minute if the host handoff runs long
Source: demos/v03/session.json
Presenter commands and spoken cues: demos/v03/runbook.md and demos/v03/demo-script.md
Visuals: original conceptual Flare illustrations, not screenshots, agent evidence or official product artwork. Presenter supplied the local headshot; it was not uploaded for generation.

## S02: Modernize the library, keep the behavior

S02 | elapsed 3-8 minutes | Task without the organizational skill
Designed timing, not a measured human rehearsal. All application data, people and policies are synthetic.
- Open 01-baseline alone in a fresh conversation and run its smoke tests and partner request
- Point out total 270, explicit null and the separate audit event; the starting app works
- Explain the midpoint example: 100.05 subtotal minus 10.01 discount plus 12 shipping equals 102.04
- Paste prompts/01-baseline.txt exactly; inspect actual changes without presuming a failure
- At minute 8 move on; do not spend the session waiting on one generation
Show: 01-baseline source, real terminal output and the exact baseline prompt
Checkpoint: 01-baseline
Exact prompt: prompts/01-baseline.txt
Evidence: Legacy behavior is already correct; only real generated output can count as an agent result
Transition: Now package the team's intent rather than repeating it in every prompt
Fallback: After 60-90 seconds of unproductive waiting, show 04-reference and identify it as prepared
Source: prompts/01-baseline.txt
Presenter commands and spoken cues: demos/v03/runbook.md and demos/v03/demo-script.md
Visuals: original conceptual Flare illustrations, not screenshots, agent evidence or official product artwork. Presenter supplied the local headshot; it was not uploaded for generation.

## S03: Start with the explanations your team repeats

S03 | elapsed 8-10 minutes | Build and review the skill with Copilot
Designed timing, not a measured human rehearsal. All application data, people and policies are synthetic.
- Switch to 02-author-skill, which has legacy code and synthetic team notes but no prewritten project skill
- Highlight pricing exceptions, wire compatibility, audit conventions and safe diagnostics
- The source already contains clues; the task is to make intent discoverable, not invent policy
- Use demos/v03/prompts/02-author-skill.txt to ask Copilot to author guidance only, not change application code
Show: knowledge/team-notes.md beside the small source tree
Checkpoint: 02-author-skill
Exact prompt: demos/v03/prompts/02-author-skill.txt
Evidence: Four synthetic requirements mapped to R1-R4
Transition: Give this knowledge a portable home
Fallback: Read one null-field note aloud and use the prepared skill to explain its translation
Source: knowledge/team-notes.md
Presenter commands and spoken cues: demos/v03/runbook.md and demos/v03/demo-script.md
Visuals: original conceptual Flare illustrations, not screenshots, agent evidence or official product artwork. Presenter supplied the local headshot; it was not uploaded for generation.

## S04: Build a reusable package

S04 | elapsed 10-14 minutes | Build and review the skill with Copilot
Designed timing, not a measured human rehearsal. All application data, people and policies are synthetic.
- Show the actual skill Copilot created, or explicitly switch to the prepared version
- Explain name and task-specific description, then inspect-first steps and concrete examples
- Keep references inside the skill directory so the exported package has no broken links
- Reject broad tool permissions, invented requirements and unrelated implementation changes
Show: .github/skills/northwind-modernization/SKILL.md and its references directory
Checkpoint: 02-author-skill
Exact prompt: demos/v03/prompts/02-author-skill.txt
Evidence: Documented repository skill structure; the package has four files
Transition: Before using generated guidance, review it like code
Fallback: Open the reviewed skill in 03-guided; call it prepared and explain one rule live
Source: https://docs.github.com/en/copilot/concepts/agents/about-agent-skills
Presenter commands and spoken cues: demos/v03/runbook.md and demos/v03/demo-script.md
Visuals: original conceptual Flare illustrations, not screenshots, agent evidence or official product artwork. Presenter supplied the local headshot; it was not uploaded for generation.

## S05: When should it apply? What would convince us?

S05 | elapsed 14-18 minutes | Build and review the skill with Copilot
Designed timing, not a measured human rehearsal. All application data, people and policies are synthetic.
- Check that the description covers migration, contract repair and small serialization reuse
- Inspect an actionable R2 rule: explicit null property, good and bad examples, unchanged assertion
- Review migration versus repair versus reuse branches so unrelated tasks do not trigger dependency changes
- Announce the prepared reviewed skill handoff into 03-guided instead of silently substituting files
- A live-authored variation is fine for teaching, but is not the predefined comparison input
Show: Skill frontmatter, concrete traps, workflow branches and review checklist
Checkpoint: 02-author-skill
Exact prompt: demos/v03/prompts/02-author-skill.txt
Evidence: Skill text and real tests, not claims about hidden activation telemetry
Transition: Start again with the same input and explicit team context
Fallback: Use the prepared checklist and stop the skill-authoring segment at minute 18
Source: .github/skills/northwind-modernization/SKILL.md
Presenter commands and spoken cues: demos/v03/runbook.md and demos/v03/demo-script.md
Visuals: original conceptual Flare illustrations, not screenshots, agent evidence or official product artwork. Presenter supplied the local headshot; it was not uploaded for generation.

## S06: Same task. Explicit team context

S06 | elapsed 18-30 minutes | Apply the skill to modernization
Designed timing, not a measured human rehearsal. All application data, people and policies are synthetic.
- Use 03-guided as its own project and a fresh conversation, never the parent folder
- Show the 18 matching legacy source/test files and four added skill files
- Paste prompts/02-guided.txt; it explicitly requests the skill
- Show only activation or file-access evidence the host actually exposes; availability alone is not use
- Run visible tests and external evaluation if there is a completed candidate
- Do not replace a candidate with the reference and call it generated output
Show: Guided prompt, skill, real diff, test output and scripts/evaluate.ps1
Checkpoint: 03-guided
Exact prompt: prompts/02-guided.txt
Evidence: Baseline and guided independent captures are currently not-run; no claimed winner
Transition: A good skill still needs a way to catch mistakes
Fallback: Run real tests in 04-reference and label it authored reference; move on at minute 30
Source: prompts/02-guided.txt
Presenter commands and spoken cues: demos/v03/runbook.md and demos/v03/demo-script.md
Visuals: original conceptual Flare illustrations, not screenshots, agent evidence or official product artwork. Presenter supplied the local headshot; it was not uploaded for generation.

## S07: One option. A broken contract

S07 | elapsed 30-32 minutes | Reproduce and repair a deliberate contract regression
Designed timing, not a measured human rehearsal. All application data, people and policies are synthetic.
- Disclose the intentional regression before showing the red test
- Open 05-null-regression and show WhenWritingNull in the serializer options
- Run SerializationTests.PreservesExplicitNull with a build of current code
- Read the real assertion about review_note existing even when its value is null
Show: Faulted setting and unchanged null-contract test
Checkpoint: 05-null-regression
Exact prompt: demos/v03/prompts/04-repair.txt
Evidence: Scripted rehearsal observes the exact intended assertion, not an arbitrary nonzero exit
Transition: Use the skill to explain and repair the mismatch
Fallback: The broken checkpoint is already prepared; do not break the source repository
Source: tests/Northwind.UnitTests/SerializationTests.cs
Presenter commands and spoken cues: demos/v03/runbook.md and demos/v03/demo-script.md
Visuals: original conceptual Flare illustrations, not screenshots, agent evidence or official product artwork. Presenter supplied the local headshot; it was not uploaded for generation.

## S08: Keep the test. Repair the implementation

S08 | elapsed 32-37 minutes | Reproduce and repair a deliberate contract regression
Designed timing, not a measured human rehearsal. All application data, people and policies are synthetic.
- Paste demos/v03/prompts/04-repair.txt and require reproduction before changes
- Reject removing or weakening the assertion as a fix
- After the minimal repair, run the exact same focused test and then the full suite
- If using set-demo-null-rule.ps1, disclose the scripted repair rather than calling it agent-generated
- These finite checks do not guarantee universal compliance
Show: Focused failure, serializer repair, same test passing and full-suite result
Checkpoint: 05-null-regression
Exact prompt: demos/v03/prompts/04-repair.txt
Evidence: Actual prepared-fixture red/green rehearsal; no fabricated agent run
Transition: Can the same skill help with a different task?
Fallback: Use the guarded scripted repair and show real tests; hard stop at minute 37
Source: scripts/set-demo-null-rule.ps1
Presenter commands and spoken cues: demos/v03/runbook.md and demos/v03/demo-script.md
Visuals: original conceptual Flare illustrations, not screenshots, agent evidence or official product artwork. Presenter supplied the local headshot; it was not uploaded for generation.

## S09: A new task. The same contract

S09 | elapsed 37-45 minutes | Reuse the skill for batch serialization
Designed timing, not a measured human rehearsal. All application data, people and policies are synthetic.
- Start a fresh conversation in 06-reuse-start and paste demos/v03/prompts/05-reuse.txt
- Add WriteBatch for existing responses without changing CLI, pricing, audit or dependencies
- Preserve item order, field names, string enums, numeric money and explicit null
- Check empty input produces an array and a null collection throws
- Check actual executed test counts; a filter matching zero tests is not success
- Prepared 07-reuse-complete has three focused tests and the full contract suite
Show: Small batch method and focused per-item equivalence tests
Checkpoint: 06-reuse-start
Exact prompt: demos/v03/prompts/05-reuse.txt
Evidence: Existing CLI, domain and audit source stay hash-identical in the prepared reuse checkpoint
Transition: Name the pieces you just watched work together
Fallback: At the cutoff, switch to 07-reuse-complete, disclose it and run its real tests
Source: demos/v03/prompts/05-reuse.txt
Presenter commands and spoken cues: demos/v03/runbook.md and demos/v03/demo-script.md
Visuals: original conceptual Flare illustrations, not screenshots, agent evidence or official product artwork. Presenter supplied the local headshot; it was not uploaded for generation.

## S10: Four tools, different jobs

S10 | elapsed 45-47 minutes | Context choices and team ownership
Designed timing, not a measured human rehearsal. All application data, people and policies are synthetic.
- The prompt stated the immediate task
- Instructions supplied broad project conventions
- The skill supplied a relevant workflow, examples and resources
- Tests checked observable cases; a person still reviewed scope and intent
- Keep this recap short: attendees have already seen the distinctions live
Show: Prompt, instructions, skill package and test files as concrete examples
Evidence: Different files with distinct responsibilities
Transition: Make the skill a maintained team asset
Fallback: Give the four definitions in one sentence and protect Q&A
Source: https://docs.github.com/en/copilot/concepts/agents/about-agent-skills
Presenter commands and spoken cues: demos/v03/runbook.md and demos/v03/demo-script.md
Visuals: original conceptual Flare illustrations, not screenshots, agent evidence or official product artwork. Presenter supplied the local headshot; it was not uploaded for generation.

## S11: Make it a team practice

S11 | elapsed 47-50 minutes | Context choices and team ownership
Designed timing, not a measured human rehearsal. All application data, people and policies are synthetic.
- Version the skill with the code, give it an owner and review changes
- Update examples and tests when the business contract changes
- Start with a narrow task rather than a company-wide standards catalog
- Close with one repeated explanation the attendee can encode tomorrow
Show: Editable ownership/review/reuse/maintenance loop
Evidence: Maintenance checklist rather than a promise of deterministic generation
Transition: Here is the complete kit; what would your first skill capture?
Fallback: Close in one minute if needed; reach resources at minute 50
Source: docs/maintenance.md
Presenter commands and spoken cues: demos/v03/runbook.md and demos/v03/demo-script.md
Visuals: original conceptual Flare illustrations, not screenshots, agent evidence or official product artwork. Presenter supplied the local headshot; it was not uploaded for generation.

## S12: Try the five-demo workflow

S12 | elapsed 50-60 minutes | Resources and protected Q&A
Designed timing, not a measured human rehearsal. All application data, people and policies are synthetic.
- Keep the public sample and official documentation visible for the protected ten-minute Q&A
- The repository includes seven local checkpoints, exact prompts, real tests, notes and fallbacks
- Publication must be verified independently of generation and deck QA
- A correct baseline or imperfect guided run is legitimate; no forced success story
- Human rehearsal and actual independent agent captures remain separate pending activities
Show: Public sample URL and official agent-skills link
Evidence: Use the publication receipt and signed-out access check, not a guessed URL
Transition: What is one rule your team keeps explaining?
Fallback: If audience access fails, share official docs and resolve sample access after the session
Source: https://docs.github.com/en/copilot/concepts/agents/about-agent-skills
Presenter commands and spoken cues: demos/v03/runbook.md and demos/v03/demo-script.md
Visuals: original conceptual Flare illustrations, not screenshots, agent evidence or official product artwork. Presenter supplied the local headshot; it was not uploaded for generation.
https://github.com/elbruno/GitHubCopilotModernizationSamples
https://docs.github.com/en/copilot/concepts/agents/about-agent-skills
