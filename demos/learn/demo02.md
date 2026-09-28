# Demo 2: Turn team knowledge into a skill

**Folder:** `02-author-skill` | **Prompt:** [`demos/v03/prompts/02-author-skill.txt`](../v03/prompts/02-author-skill.txt)

## What you'll learn

How to turn the explanations a team keeps repeating into a custom Copilot
skill, and how to review that skill before you trust it.

## Steps

1. Open `$demo\02-author-skill` and read `knowledge/team-notes.md`. Four
   fictional teammates explain the rules they repeat in every code review:
   pricing, the JSON contract, the audit path and safe error messages.
2. Start a fresh Copilot conversation in that folder.
3. Paste the contents of `demos/v03/prompts/02-author-skill.txt`. It asks
   Copilot to write a skill only, not to change the app.
4. Open the new `.github/skills/northwind-modernization/SKILL.md`.

## What to look for

A good skill has:

- **A name and a focused description.** The description is how Copilot
  decides when the skill is relevant. It should cover this app's migration,
  contract repairs and small serialization changes. Nothing broader.
- **Concrete rules with examples.** For example: `review_note` must be
  present even when it's null, with a good example and a bad example.
- **Steps to follow and evidence to report**, such as which tests to run.
- **References inside the skill folder**, so the folder works when copied.

Watch out for:

- Rules that aren't in the team notes (invented policy)
- Broad tool permissions
- Changes to the app code

## Review questions

1. When should this skill apply?
2. What evidence would convince you the work is right?

## What it means

A skill description helps Copilot choose the skill. It doesn't guarantee
every rule is followed. That's why each rule should connect to a test.

Compare with the reviewed skill in
[`.github/skills/northwind-modernization`](../../.github/skills/northwind-modernization/SKILL.md),
which is also in `03-guided`.
