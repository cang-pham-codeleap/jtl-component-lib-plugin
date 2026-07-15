# task-to-pr v2 pressure tests

Evidence index for PR readiness. Logs live in this directory.

| # | Skill / area | RED log | GREEN log | Spec scenario |
|---|--------------|---------|-----------|---------------|
| 1 | mcp-fetcher contract | [01-mcp-fetcher.md](./01-mcp-fetcher.md) | smoke (same log) | agent contract (haiku, read-only, summary/verbatim) |
| 2 | ticket-intake injection | [02-ticket-intake-baseline.md](./02-ticket-intake-baseline.md) | [02-ticket-intake-with-skill.md](./02-ticket-intake-with-skill.md) | embedded instructions fenced / injection stop |
| 3 | verify-ticket exists | [03-verify-ticket-baseline.md](./03-verify-ticket-baseline.md) | [03-verify-ticket-with-skill.md](./03-verify-ticket-with-skill.md) | ALREADY-EXISTS + deep-explore claim |
| 4 | create-pr diff major | [04-create-pr-baseline.md](./04-create-pr-baseline.md) | [04-create-pr-with-skill.md](./04-create-pr-with-skill.md) | feat removes prop → diff-verified breaking change |
| 5 | reflect draft-first | [05-reflect-baseline.md](./05-reflect-baseline.md) | [05-reflect-with-skill.md](./05-reflect-with-skill.md) | no silent post; draft then approve |
| 6 | hub clarify menu | [06-hub-clarify-baseline.md](./06-hub-clarify-baseline.md) | [06-hub-clarify-with-skill.md](./06-hub-clarify-with-skill.md) | ≥3 solutions first |
| 7 | hub Stage 2 spec | [07-hub-stage2-baseline.md](./07-hub-stage2-baseline.md) | [07-hub-stage2-with-skill.md](./07-hub-stage2-with-skill.md) | Speckit removed; superpowers design → workflow `specs.md` only |
| 8 | intake SoT / vague / no-ref / clarify skip | [08-intake-clarify-policy.md](./08-intake-clarify-policy.md) | same (contracts) | dual SoT, vague gate, create-ticket handoff, Stage 1 fast-path |
| 9 | figma-fetching under pressure | [09-figma-fetching-baseline.md](./09-figma-fetching-baseline.md) | [09-figma-fetching-with-skill.md](./09-figma-fetching-with-skill.md) | Figma URLs → mcp-fetcher design-context; no invent-from-AC |

## Deliverable tree (Task 8 confirm)

All paths present:

```
plugins/comp-lib-process/agents/mcp-fetcher.md
plugins/comp-lib-process/skills/ticket-intake/SKILL.md
plugins/comp-lib-process/skills/figma-fetching/SKILL.md
plugins/comp-lib-process/skills/create-ticket/SKILL.md
plugins/comp-lib-process/skills/verify-ticket/SKILL.md
plugins/comp-lib-process/skills/reflect/SKILL.md
plugins/comp-lib-process/skills/create-pr/SKILL.md
plugins/comp-lib-process/skills/task-to-pr/SKILL.md
plugins/comp-lib-process/skills/task-to-pr/references/automation.md
```

## Authoring environment

- **Model:** varied (haiku / sonnet / general-purpose subagents)
- **Harness:** Claude Code
- **Harness version:** 2.1.210
- **Plan execution:** `superpowers:subagent-driven-development`
- **Plugins:** `comp-lib-process`, `superpowers`, `context-mode`

## PR notes (target: `main`)

- Skills superseded/conflicts: personal `verify-gh-issue` unchanged; v1 monolithic ship/Jira steps moved to `reflect` + `create-pr`
- Pressure-test evidence: this directory
- Do not open GitHub PR from this task unless asked — evidence pack only
