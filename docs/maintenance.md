# Maintaining the sample and skill

Review changes through the repository's normal code-review process.

When a rule changes, update the rule catalog, skill reference, implementation
and tests together. Record why the observable contract is changing instead of
silently weakening assertions. Keep skill frontmatter minimal and supporting
links inside its package.

For dependency updates: change pinned versions deliberately, regenerate
lockfiles, run restore audits and `scripts/verify.ps1`, then retest the
exported demo folders.

Keep the full repository separate from the folders Copilot works in. Freeze
the legacy fixture and evaluator before comparing runs. If either changes,
create new exports and reports rather than reusing old results. Keep failed
runs and label corrections. Hashes establish file identity, not the
truthfulness of manually entered metadata.

Review the official product docs before relying on specific behavior. Host
support, installed agents, model names and skill-loading behavior can change.
