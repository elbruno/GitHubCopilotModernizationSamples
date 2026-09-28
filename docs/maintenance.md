# Maintaining the sample and skill

Owner for this synthetic session: Bruno Capuano. Review changes through the
repository's normal code-review process.

When a rule changes, update the rule catalog, skill reference, implementation,
tests, and presenter examples together. Record why the observable contract is
changing instead of silently weakening assertions. Keep skill frontmatter
minimal and supporting links inside its package.

For dependency updates: change pinned versions deliberately, regenerate lockfiles,
run restore audits and `scripts/verify.ps1`, then retest independent exports.
The deck uses PptxGenJS 4.0.1 with patched `image-size` 2.0.4 overridden because
its default 1.x dependency has published denial-of-service advisories. This
deck uses no images. Validate image API compatibility before adding image assets.

Keep the full repository separate from baseline/guided input roots. Freeze
the legacy fixture and evaluator before generation. If either changes,
create new exports and reports rather than reusing old capture evidence.
Retain failed runs and label corrections. Hashes establish file identity, not
truthfulness of manually entered metadata.

Slide source is `slides/content.mjs`. Rebuild with `npm run slides:build`;
embedded notes, standalone notes and outline are generated from that source.
The prior deck is archived locally under `slides/dist/history` before rebuild.
A changed deck hash invalidates native/visual evidence; render to a new round.
Do not manually edit generated notes and expect changes to survive a rebuild.

Review official product docs shortly before each presentation. Host support,
installed agents, model names and skill-loading behavior can change. Record
observations and leave untested routes explicitly unverified.
