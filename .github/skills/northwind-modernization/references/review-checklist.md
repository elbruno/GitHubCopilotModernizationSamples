# Completion evidence

- R1: Run all example prices, midpoint rounding and post-discount shipping.
- R2: Compare parsed JSON fields/types/nulls, not whitespace. Test every
  missing/null field, unknown/duplicate/case differences, numeric ranges,
  malformed JSON, file/stdin equivalence, help and error exit codes.
- R3: Use a test audit spy to assert one event through the interface. Inspect
  stderr shape and normalized correlation; inspect source for bypasses.
- R4: Inspect complete diagnostic output on success and failures for unique
  synthetic sentinels; review error handlers for raw exception/request dumps.
- Migration: no Newtonsoft.Json reference in app or dependency graph; restore,
  build and visible tests succeed. Update lockfiles; no unrelated refactor.
- Repair: record the original failing assertion, then rerun it unchanged after
  the fix. A deliberate teaching regression is not an observed agent failure.
- Reuse: compare every batch item's parsed JSON with the single-response
  serializer; preserve order, empty-array behavior and null-input rejection.
  Confirm no CLI, pricing, audit or dependency changes. Apply migration checks
  only when the requested task actually changes the serialization library.
- Summarize changed files and rule-to-test evidence with actual command results.
  Report untested paths and human intervention explicitly. Passing tests do
  not make the sample production-ready.
