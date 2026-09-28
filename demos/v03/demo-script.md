# Demo script: v03

Use this beside [exact commands](runbook.md). Lines in quotes are suggested
spoken words, not recordings or claims that a live agent run already happened.
Use the prompt files verbatim rather than retyping an approximation.

## Opening | 0-3 | slide 1

**Say:** "Every team has someone who says: yes, that works, but that is not how
we do it here. Today we will turn that explanation into a Copilot skill."

**Show:** the title and presenter photo, then the small app tree.

**Say:** "One app, one skill, five demos: try the task, build the skill, use it,
test its limits, reuse it. All data and rules are synthetic."

**Transition:** "First, what happens when we only state the technology change?"

## Demo 1 | 3-8 | slide 2

**Show:** `01-baseline` only. Run smoke tests and the partner request.

**Say:** "This legacy app works. Total 270, an explicit null field, and a
separate audit event are intentional. We are not beginning with broken code."

**Paste:** `prompts/01-baseline.txt`.

**While Copilot works:** show the old serializer. Point out the explicit enum
and null behavior. Explain the midpoint example verbally: subtotal 100.05,
discount 10.01, shipping 12, total 102.04.

**Review:** "What changed, what stayed the same, and what evidence do we have?"
If it is correct: "Good. The baseline is allowed to succeed."

**Fallback line:** "This is my prepared reference, not output from this run.
It lets us inspect the intended migration without waiting on generation."

**Transition:** "Now let us make the team's intent reusable."

## Demo 2 | 8-18 | slides 3-5

**Show:** `02-author-skill/knowledge/team-notes.md`. Highlight the integration
note about explicit null and the prohibition on customer data in diagnostics.

**Say:** "These are fictional team conversations, not an executable policy.
Copilot can help structure them, but we must review what it writes."

**Paste:** `demos/v03/prompts/02-author-skill.txt`.

**Show:** the actual created `.github/skills/northwind-modernization/SKILL.md`.
If unavailable, open the prepared counterpart in `03-guided` and disclose it.

**Walk through five things:** name; description/when relevant; inspect-first
workflow; R1-R4 with examples; supporting references and verification.

**Say:** "A useful description tells Copilot when this skill matters. It is
not a magic command or a promise that every rule will be followed."

**Edit/explain one rule:** dropping `review_note` is not stylistic cleanup.
Pair the requirement with a good example, a bad example and a test.

**Say:** "References stay inside the skill folder, so the package survives
copying to another project. We have not given broad tool permissions."

**Handoff:** "For the next demo I will use the reviewed, prepared version of
this skill. That keeps the starting inputs predictable."

## Demo 3 | 18-30 | slide 6

**Show:** `03-guided` in a fresh conversation, then its skill folder.

**Say:** "The source and smoke tests match our first starting point. The
additional context is the four-file skill package. Personal and host context
still need separate review, so this is not automatically a controlled study."

**Paste:** `prompts/02-guided.txt`.

**Say:** "This prompt explicitly requests the skill. I will show only the
activation or file-access evidence the host actually exposes."

**Review the real diff:** shared output options; lowercase string enum;
explicit null; unchanged pricing; audit interface; safe errors.

**Run:** visible tests, then external evaluation if a finished candidate is
available. Show failures as well as passes. Do not invent an improvement score.

**Fallback:** "This folder is the authored reference. These tests are real,
but they are not evidence that an independent Copilot run produced this code."

**Transition:** "Even with a good skill, why do we still need tests?"

## Demo 4 | 30-37 | slides 7-8

**Say first:** "I deliberately changed one serializer option in this copy.
This is a teaching regression, not a captured Copilot error."

**Show:** `05-null-regression` with `WhenWritingNull`; run only
`SerializationTests.PreservesExplicitNull`.

**Read the real failure:** "R2: review_note must exist even when its value is
null." Explain why moving or removing the assertion would hide the defect.

**Paste:** `demos/v03/prompts/04-repair.txt`.

**If slow:** announce the scripted fallback and invoke `set-demo-null-rule.ps1`.
Do not call that fix Copilot-generated.

**Run:** the unchanged focused test and then the full suite.

**Say:** "The skill carried the reason. The test detected this specific
regression. Review connects the two. Neither proves every possible behavior."

## Demo 5 | 37-45 | slide 9

**Show:** `06-reuse-start`, a fresh conversation and the same skill.

**Say:** "We are done migrating libraries. Can the knowledge help with a
different change: serializing two existing quote responses as an array?"

**Paste:** `demos/v03/prompts/05-reuse.txt`.

**Review:** `WriteBatch` reuses output options, preserves order/nulls/enums,
handles empty and null input, and leaves pricing, audit and the CLI alone.

**Run:** the actual added tests. Read the executed count, not only the exit
code; a test filter matching nothing is not evidence.

**Fallback:** open `07-reuse-complete`; say it is prepared. Show the three
focused tests executing and the existing contract suite remaining green.

**Transition:** "That is the payoff: we reused the team's knowledge, not just
the wording of the original migration prompt."

## Recap | 45-50 | slides 10-11

**Say:** "The prompt asked for a change. Instructions supplied broad project
conventions. The skill supplied relevant know-how. Tests checked defined
behavior. People still reviewed the result."

**Say:** "Version the skill, give it an owner, and update examples and tests
together. Your first skill does not need to encode your entire company."

**Closing:** "Pick one task. Capture one explanation you keep repeating.
Make it actionable. Check it. Reuse it."

## Resources and Q&A | 50-60 | slide 12

Show the public sample and official skill docs. Check public access before the
session. Keep resources visible throughout Q&A.

If asked whether the guided version is always better: "No. We check real
outputs. A correct baseline and an imperfect guided run are both legitimate
results. The reusable asset is the explicit knowledge and review process."
