---
applyTo: "**"
description: Portable JTL component-library task workflow instructions.
---

# JTL Component Library Agent Instructions

Use installed skills from `.agents/skills/` when their descriptions match the
task. For ticket-driven work, use `task-to-pr` and store committed, sanitized
evidence only in `.jtl/workflow/<ticket-id>/`.

`superpowers:brainstorming` and `superpowers:writing-plans` are required for
FULL-tier task-to-PR design and planning. If Superpowers is unavailable, stop
before those stages and install it for the active harness:

```bash
copilot plugin marketplace add obra/superpowers-marketplace
copilot plugin install superpowers@superpowers-marketplace
```

Never commit raw ticket bodies, comments, Figma payloads, secrets, or personal
data to workflow evidence. Do not bypass human approval blocks or required CI.
