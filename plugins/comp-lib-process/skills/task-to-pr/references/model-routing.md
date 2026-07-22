# Subagent model routing (balanced profile)

Single source of truth for which model each `comp-lib-process` agent prefers.
Each agent's own frontmatter carries this as a prioritized `model:` array —
this file explains the policy and is where routing changes land first; do not
fork the table into other files.

## Why this exists

Agent frontmatter previously used a bare Claude Code alias (`haiku` / `sonnet`
/ `inherit`). Claude Code resolves those; other harnesses generally do not
match a bare alias to a registered model ID, so an unresolved alias silently
falls back to the parent/coordinator model — making every subagent as
expensive as the coordinator regardless of the role's actual needs.

Per the [VS Code custom-agent spec](https://code.visualstudio.com/docs/agent-customization/custom-agents#_header-optional),
`model:` accepts "a single model name (string) or a prioritized list of
models (array)"; VS Code "tries each model in order until an available one is
found." Each agent below now declares that array directly in frontmatter —
primary first, one fallback — so a fresh plugin install resolves to the
intended model out of the box, with no orchestrator-side patching required.

**Cross-harness note:** qualified `<Model Name> (copilot)` entries are VS
Code/GitHub Copilot identifiers. A harness that only understands Claude's
bare aliases (`haiku`/`sonnet`/`opus`/`inherit`) will not resolve these and
falls back to its own default — verify behavior on any non-VS Code harness
before relying on the array there.

## Balanced routing table

| Agent                   | Primary                     | Fallback                    | Why                                                            |
| ----------------------- | --------------------------- | --------------------------- | -------------------------------------------------------------- |
| `mcp-fetcher`           | Claude Haiku 4.5 (copilot)  | MAI-Code-1-Flash (copilot)  | Mechanical read-only fetch/summarize                           |
| `deep-explore`          | GPT-5.4 mini (copilot)      | Claude Haiku 4.5 (copilot)  | Optimized for codebase exploration / grep-style tools          |
| `planner`               | Claude Opus 4.8 (copilot)   | GPT-5.6 Sol (copilot)       | Deep reasoning for architecture/decomposition                  |
| `engine-specialist`     | GPT-5.3-Codex (copilot)     | Claude Sonnet 4.6 (copilot) | Agentic implementation, edit/test loops                        |
| `ui-ux-stylist`         | Claude Sonnet 4.6 (copilot) | GPT-5.3-Codex (copilot)     | Frontend reasoning, accessibility, implementation quality      |
| `code-quality-reviewer` | Claude Sonnet 4.6 (copilot) | GPT-5.4 (copilot)           | Independent multi-file reasoning without Opus-tier cost        |
| `quiz-taker`            | Claude Haiku 4.5 (copilot)  | MAI-Code-1-Flash (copilot)  | Constrained comprehension check, no reasoning needed           |
| `tech-debt-reviewer`    | Claude Sonnet 4.6 (copilot) | GPT-5.4 (copilot)           | Standalone debt review only — not dispatched from `task-to-pr` |

## Escalation only

Use a stronger model (GPT-5.5, GPT-5.6 Sol, Claude Opus 4.x, Claude Fable 5)
only when one applies: security-sensitive or architecture-heavy change, very
large/interconnected codebase, a disputed or repeatedly failing verdict, or a
genuinely large context requirement. These are not Stage 4/5 defaults.

## Constraints

- A requested subagent model cannot exceed the parent/coordinator's cost
  tier — the harness falls back to the parent model when it does. Keep the
  coordinator capable enough to permit the workers above.
- Model availability depends on Copilot plan, organization policy, IDE
  version, and rollout stage — treat this table as intent, not a guarantee.
  The model picker in the active harness is authoritative.
- Do not copy this table into other files. Link here instead.
