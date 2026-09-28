# Demo troubleshooting

| Symptom | Recovery |
| --- | --- |
| SDK unavailable | Run doctor; install SDK matching global.json yourself. Do not silently retarget |
| Restore slow/offline | Use the previously restored rehearsal folders and `--no-build`; say the cache was prepared |
| Restore NU1004 | Dependency lock is stale; regenerate only after intentional package changes, then revalidate |
| No Copilot/network | Use the labeled legacy/reference walkthrough; no need for an account to execute restored code |
| Skill not visibly activated | Explicitly request the named skill using the prepared prompt and disclose any intervention; do not invent telemetry |
| Baseline passes everything | Show it. The point is discoverable intent and reviewability, not guaranteed failure |
| Guided result fails | Preserve original output/report, diagnose the criterion, label any corrected result separately |
| Comparison says not-run | Supply a genuine completed, sealed capture; never change a status just to get green |
| Comparison blocked | Read logs/metadata mismatch. Missing evaluator or SDK is infrastructure, not behavior |
| Existing export/report directory | Choose a fresh name; scripts deliberately do not delete or overwrite evidence |
| Ancestor context rejection | Pick a neutral output parent; do not disable the safety check |
| CLI inventory differs from app | Expected possibility: host-projected app instructions are not in CLI inventory. Inspect both |
| Native PDF/export prompt error | Use updated renderer; its already-approved internal PDF step uses `-Confirm:$false` |
| PowerPoint unavailable | Use saved PPTX/PDF after visual review or the outline. Structural checks alone are not visual approval |
| Generated deck changed | Prior render hash is stale; render to a new round and inspect again |
| Public URL missing | Verify/configure the correct repository with owner approval, publish intentionally, then update resources and slide 12 |
| Time running short | Cut optional reuse, keep comparison and closing; follow the 45-minute core path |

No remediation requires cloud provisioning, a database, a container or a new
credential. Never display raw errors from tools if they include private paths
or account details; use the prepared source and synthetic app output instead.
