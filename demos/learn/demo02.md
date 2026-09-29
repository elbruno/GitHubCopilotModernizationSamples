# Demo 2: Turn team knowledge into a skill

**Folder:** `02-author-skill` | **Prompt:** [`demos/v03/prompts/02-author-skill.txt`](../v03/prompts/02-author-skill.txt)

## What you'll learn

How to turn the explanations a team keeps repeating into a custom Copilot
skill, and how to review that skill before you trust it.

## Open the demo

First complete [setup](README.md). In the **same PowerShell window**:

```powershell
. (Join-Path $kit 'scripts\open-demo.ps1') -Demo 2
```

This opens VS Code, changes to the demo directory and sets `$demo` and `$prompt`.
Keep using this PowerShell window for commands; use VS Code for code and Chat.
In a new terminal, first set `$kit` to the full path of your cloned repository.
No prompts or answer files are copied into the isolated demo input.

## Steps

1. Read the team notes. In VS Code press **Ctrl+P**, paste the `file:line`
   value and press Enter (or open the file and press **Ctrl+G** for the line):

   | Ctrl+P (file:line) | Current state |
   | --- | --- |
   | `knowledge\team-notes.md:5` | Line 5: Maya (finance): partner discount, rounding, shipping |
   | `knowledge\team-notes.md:9` | Lines 9-11: Alex (integration): lowercase enum, numbers, `review_note: null` |
   | `knowledge\team-notes.md:13` | Line 13: Sam (platform): audit through `IAuditTrail` only |
   | `knowledge\team-notes.md:16` | Lines 16-18: Jo (privacy): no request data in errors or logs |
   | `src\Northwind.Quotes\QuoteJson.cs:18` | Lines 18-23: the existing serializer already follows these rules |
   | `src\Northwind.Quotes\Northwind.Quotes.csproj:7` | Line 7: still Newtonsoft.Json; this demo only writes a skill |

2. Start a **fresh** Copilot Chat in Agent mode in that VS Code window.
3. Paste the prompt. It is 14 lines, so it is not repeated here. Copy it from
   the file `demos\v03\prompts\02-author-skill.txt` in your clone (the full path
   is printed by `open-demo.ps1` and stored in `$prompt`), or open
   [the prompt on GitHub](../v03/prompts/02-author-skill.txt) and click
   **Copy raw file**. It asks Copilot to write a skill only, not to change the app.
4. Open the new `.github\skills\northwind-modernization\SKILL.md`.

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

## Compare with the reviewed skill

Open the reviewed version from `03-guided` in the same VS Code window:

```powershell
code -r -g "$(Join-Path $demo '03-guided\.github\skills\northwind-modernization\SKILL.md'):3"
```

| Line | What to compare |
| --- | --- |
| 3 | `description:`: when the skill applies |
| 25-26 | R2: snake case, lowercase enums, explicit `review_note` null |
| 36-38 | Good and bad examples (`WhenWritingNull` is the bad one) |
| 51-58 | Workflow branches: migration, repair, reuse |

It's also in this repository:
[`.github/skills/northwind-modernization`](../../.github/skills/northwind-modernization/SKILL.md).

## What it means

A skill description helps Copilot choose the skill. It doesn't guarantee
every rule is followed. That's why each rule should connect to a test.

**Next: [Demo 3](demo03.md).** Do not run setup again.
