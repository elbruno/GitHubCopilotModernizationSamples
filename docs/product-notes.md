# Product and environment notes

Reviewed September 28, 2026. The event title is **From Tribal Knowledge to Code:
Custom Skills for GitHub Copilot Modernization**.

This is a dependency/API modernization using general Copilot app agent mode:
Newtonsoft.Json to System.Text.Json on .NET 10. It is neither an end-to-end
Azure migration nor a .NET Framework conversion.

## Observed environment

| Item | Observation |
| --- | --- |
| SDKs installed | 9.0.318 and 10.0.401; sample pins supported .NET 10 SDK 10.0.401, latest patch roll-forward, no previews |
| Target | net10.0; no SDK installation was needed |
| Node / npm | v24.19.0 / 11.8.0; Node 24 LTS; PptxGenJS 4.0.1 |
| Newtonsoft.Json | 13.0.4 pinned; restore audit enabled for all packages |
| Tests | xUnit 2.9.3, VS runner 3.1.4, Test SDK 17.14.1; lockfiles retained |
| Authoring host | GitHub Copilot app, CLI session runtime 1.0.87-0 as exposed to this session |
| Authoring model | GPT-6 Astra (`gpt-6-astra`), exposed by host; not an independent demo model measurement |
| Installed standalone CLI | `copilot --version` reported 1.0.88; first invocation had a transient extraction EPERM warning, then succeeded |
| Copilot independent generation | Not run; neutral personal/global context isolation has not been established |
| PowerPoint | Desktop executable found; native render result recorded separately |
| Repository separation | Internal production origin is private. Designated public sample checkout initially has no remote; attendee access is not yet established |

No broad tool-preapproval or permission-bypass setting is used in this demo.
CLI `--help`, `skill --help`, and `instruction --help` were inspected before
documenting commands. CLI lists both instruction inspection and skill inspection.
These do not establish app authentication or prove that a particular skill
was loaded in a different session. Do not infer a neutral app profile from
`--no-custom-instructions`: it does not establish that personal skills,
plugins, app-level instructions, or memories have been excluded.

The read-only CLI inventory found 3 project, 10 personal-agents, 8 personal-copilot,
6 plugin and 2 built-in skills at this point in authoring. The project inventory
included northwind-modernization. This establishes discovery, not adherence
in an independent run. The current session exposes personal and project skills.
They have not been removed or disabled. Inventory the intended demo environment
locally before a fresh session; do not publish private configuration contents.
If isolation cannot be demonstrated, say **contextual walkthrough**, not
controlled before/after experiment.

## Official sources checked

The following URLs were fetched successfully at the review date. No different
canonical destination was observed; Microsoft Learn canonical metadata matched.
Descriptions are paraphrases, not promises of installed features.

| Source | Verified statement |
| --- | --- |
| [Reactor](https://developer.microsoft.com/en-us/reactor/events/27594/) | Exact title, September 29, 17:00-18:00 UTC (13:00-14:00 America/New_York) |
| [Agent skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills) | Repository and personal skills; Copilot app is a supported host |
| [Adding skills](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/add-skills) | `.github/skills/<name>/SKILL.md`, YAML name and description; relevance-based loading |
| [App customization](https://docs.github.com/en/copilot/how-tos/github-copilot-app/customize-github-copilot-app) | Customize > Skills; configured repository/CLI skills available in app; app and project instructions also exist |
| [Upgrade overview](https://learn.microsoft.com/en-us/dotnet/core/porting/github-copilot-upgrade/overview) | Library/framework upgrades; app Agent picker documents `Upgrade` |
| [.NET scenarios](https://learn.microsoft.com/en-us/dotnet/core/porting/github-copilot-upgrade/dotnet-scenarios-and-skills) | Newtonsoft.Json replacement is a supported scenario |
| [Modernization overview](https://learn.microsoft.com/en-us/dotnet/azure/migration/appmod/overview) | Azure-oriented migration agent, distinct from dependency upgrades |

## Dedicated Upgrade route: unverified locally

Docs describe selecting **Upgrade** in the app Agent picker. Its installed
availability and consumption of this repository skill have **not** been tested.
Use general app agent mode for the prepared operator prompts. Do not equate
this open repository skill with the Upgrade product's built-in capabilities.
No dashboard, slash command, automatic activation log, or independent run is
simulated. If trying Upgrade later, record its actual context/skill behavior
and do not mix its result with a general-agent baseline.

Skills guide; tests check defined cases; people review. Skills are not policy
enforcement, a security boundary, or a guarantee of compliant output.
