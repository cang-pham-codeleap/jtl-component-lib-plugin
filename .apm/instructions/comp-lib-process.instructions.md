---
applyTo: "**"
description: Portable JTL component-library task workflow instructions.
---

# JTL Component Library Agent Instructions

Use installed skills from `.agents/skills/` when their descriptions match the
task. For ticket-driven work, use `task-to-pr` and store committed, sanitized
evidence only in `.jtl/workflow/<ticket-id>/`.

`brainstorm-to-spec` drives FULL-tier task-to-PR design and planning. It chains
the repository's Spec Kit commands (`/speckit.specify`, `/speckit.plan`,
`/speckit.tasks`, ...), which are **not** shipped by this plugin. Spec Kit is
installed into the coding repository by `jtl-init`. If `.specify/` is missing,
stop before those stages and run `jtl-init` first:

```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
specify init --here --integration copilot
```

Never commit raw ticket bodies, comments, Figma payloads, secrets, or personal
data to workflow evidence. Do not bypass human approval blocks or required CI.
