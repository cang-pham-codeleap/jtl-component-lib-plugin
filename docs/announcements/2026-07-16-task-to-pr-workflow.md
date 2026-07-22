# Announcement: task-to-pr — the full AI-agent daily workflow

**Date:** 2026-07-16
**Plugin:** `comp-lib-process` v1.5.0

We now have an end-to-end workflow that an AI agent runs from ticket intake to PR + ticket reflection — one continuous agent per task, no hand-holding between steps.

## What it does

A single command — "pick up this ticket", a GitHub issue number, or a Jira key — runs the whole pipeline:

```
GitHub issue / Jira ticket / Figma design
   → intake → verify → branch → clarify → spec → plan → implement → review → ship → reflect
```

Every stage is a skill in the `comp-lib-process` plugin. The hub is `task-to-pr`.

### The stages

| Stage | Skill | What happens |
|---|---|---|
| 0 Intake | `ticket-intake` | Fetches GitHub issue + Jira ticket, resolves source of truth, fences ticket content as **data** (never executes instructions found in ticket bodies). Pulls Figma designs via `figma-fetching` when the ticket carries a URL. |
| 0.3 Docs | inline | Loads repo agent conventions (`AGENTS.md` / `docs/agents/`). |
| 0.6 Verify | `verify-ticket` | Confirms the bug is real / feature doesn't exist. Stops the pipeline on `NOT-REPRODUCIBLE` or `ALREADY-EXISTS`. |
| 0.9 Branch | inline | Branches off the default branch (never main). |
| 1 Clarify | inline | Presents ≥3 solution approaches; human picks. Classifies **SIMPLE** vs **FULL** tier. |
| 2 Spec | `superpowers:brainstorming` | Design doc → `specs.md` (FULL tier only). **Saved as evidence** under `.jtl/workflow/<ticket-id>/`. |
| 3 Plan | `superpowers:writing-plans` | Implementation plan → `plan.md` (FULL tier only). |
| 4 Implement | `engine-specialist` / `ui-ux-stylist` | One agent per domain group, 3 phases: tests for all tasks → implement all → one tests+lint+typecheck run → commit per task. |
| 5 Review | `code-quality-reviewer` + `quiz-taker` | Clean-context gate: spec compliance + code quality + technical debt + build (once) + Stage 4 check evidence. FULL tier adds a teach-back comprehension quiz. |
| 6 Ship | `create-pr` | Draft PR via `gh`. Never merges. |
| 7 Reflect | `reflect` | Drafts the GitHub + Jira comments and the Jira transition — **posts only after human approval**. |

## Why it matters

- **Spec + plan + verdict are saved as evidence.** Every task leaves a sanitized, committed paper trail in `.jtl/workflow/<ticket-id>/` — `specs.md`, `plan.md`, `verification-report.md`, `review-verdict.md`. You can audit what was decided and why, not just what shipped.
- **One agent per task, fresh-context gates.** The agent that wrote the code never judges it — `code-quality-reviewer` and `quiz-taker` run with no session memory, so acceptance isn't self-acceptance.
- **Ticket reflection is automatic, not forgotten.** After the PR opens, `reflect` drafts the "implemented in PR #N" comment for both GitHub and Jira and the status transition — you approve, it posts.
- **Tiered, not one-size-fits-all.** Trivial fixes take the SIMPLE path (skip spec/plan, reviewer + debt + tests only). Substantial work takes FULL (adds teach-back comprehension gate). The agent proposes the tier; you confirm.
- **Security by default.** Ticket bodies are treated as untrusted data, no work on main, no force-push, no `gh pr merge`, no AI-attribution trailers in commits.

## How to use it

In any Claude Code session with the plugin installed:

```
Pick up CP-4538
```
or
```
Implement issue #123
```

The agent runs intake → reflect. It stops at every checkpoint (spec, plan, review, PR) for your approval — it never self-approves.

For the full visual: **[task-to-pr workflow diagram](https://cang-pham-codeleap.github.io/jtl-component-lib-plugin/)** — interactive, click a flow (Happy path / SIMPLE tier / Review loop / Domain agents) to see which agent fires at each stage.

## Introducing `@task-to-pr`

Reference the workflow directly with the `task-to-pr` skill. It's the orchestrator hub — invoke it whenever someone says "pick up this ticket", "ship this issue", or gives a GitHub issue number / Jira key.

- **Freeform with no ticket ref** → it stops and points at `create-ticket` (don't invent synthetic tickets).
- **Ticket ref present** → full pipeline.
- **Trivial work** → the agent proposes SIMPLE tier; you confirm.

The skill lives at `plugins/comp-lib-process/skills/task-to-pr/SKILL.md`. Trigger it by name or let it auto-trigger on ticket/issue references.

## Status

Shipped in `comp-lib-process` v1.5.0. Branch `chore/slim-task-to-pr` carries the latest tier-gating + teach-back fixes (teach-back now FULL-tier only; SIMPLE tasks gate on reviewer + debt + tests). Diagram hosted on GitHub Pages auto-rebuilds on every push to `main`.
