# comp-lib-process

AI coding agent skills, subagents, commands, and hooks for the JTL component
library development workflow. This is the plugin
source published to the `jtl-component-lib-plugin` marketplace as
`comp-lib-process@jtl-component-lib-plugin` — see the [repo root README](../../README.md)
for installation instructions.

## What this plugin does

Orchestrates the full ticket-to-PR lifecycle for the component library —
intake, verification, design fetch, planning, implementation, review, debt
tracking, and PR creation — while enforcing a context-discipline pattern
(exploration is routed through a cheap subagent instead of flooding the main
session with raw file reads).

## Dependencies

Declared in [`.claude-plugin/plugin.json`](.claude-plugin/plugin.json) and
auto-installed from their marketplaces when this plugin is installed:

| Plugin         | Marketplace               | Purpose                                                                            |
| -------------- | ------------------------- | ---------------------------------------------------------------------------------- |
| `caveman`      | `caveman`                 | Compressed subagent communication mode                                             |
| `ponytail`     | `ponytail`                | Anti-over-engineering review/authoring discipline                                  |
| `context-mode` | `context-mode`            | Sandboxed processing so raw tool output doesn't bloat context                      |
| `superpowers`  | `claude-plugins-official` | Required for FULL-tier `task-to-pr` design/planning (brainstorming, writing-plans) |

## MCP servers

[`.mcp.json`](.mcp.json) registers **codegraph** (`codegraph serve --mcp`), a
local SQLite knowledge graph of the target codebase's symbols and call
edges — used by `deep-explore` and other agents in place of grep/Read loops.

## Directory layout

```
agents/     Subagent definitions (Task/Agent tool targets)
commands/   Slash commands
docs/       (reserved for generated docs)
hooks/      PreToolUse/Stop hook wiring
scripts/    Hook shell scripts
skills/     Workflow skills (SKILL.md + supporting assets)
.mcp.json   codegraph MCP server registration
```

## Skills

| Skill                                                                            | Use when                                                                                                                   |
| -------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| [`task-to-pr`](skills/task-to-pr/SKILL.md)                                       | User references a GitHub issue/Jira key or says "pick up/implement/ship this ticket" — orchestrates intake → PR end to end |
| [`ticket-intake`](skills/ticket-intake/SKILL.md)                                 | Pull GitHub/Jira ticket content into `task-context.md`; resolve dual GH+Jira sources                                       |
| [`verify-ticket`](skills/verify-ticket/SKILL.md)                                 | Validate a ticket's claim (bug real? feature exists?) before branching/build                                               |
| [`figma-fetching`](skills/figma-fetching/SKILL.md)                               | A Figma design URL appears in a ticket or message                                                                          |
| [`create-ticket`](skills/create-ticket/SKILL.md)                                 | Freeform work with no GitHub issue/Jira key yet                                                                            |
| [`create-jira-ticket`](skills/create-jira-ticket/SKILL.md)                       | Create/file a new Jira ticket in the CP project, or write one in the same format as a reference ticket                     |
| [`debt-review`](skills/debt-review/SKILL.md)                                     | Check technical debt on the current PR/branch vs `main`                                                                    |
| [`resolve-pr-comment`](skills/resolve-pr-comment/SKILL.md)                       | Verify and fix open PR review threads before merge                                                                         |
| [`reflect`](skills/reflect/SKILL.md)                                             | Notify the ticket (GitHub/Jira comment + transition) after a PR exists                                                     |
| [`create-pr`](skills/create-pr/SKILL.md)                                         | Create a PR — version bump detection, changelog, draft PR, PR description                                                  |
| [`teach-back-verification`](skills/teach-back-verification/SKILL.md)             | Before claiming multi-file work is done; comprehension-quiz gate                                                           |
| [`shadcn`](skills/shadcn/SKILL.md)                                               | Adding, searching, fixing, or styling shadcn/ui components                                                                 |
| [`html-diagram`](skills/html-diagram/SKILL.md)                                   | Produce a self-contained HTML/SVG architecture diagram                                                                     |
| [`improve-codebase-architecture`](skills/improve-codebase-architecture/SKILL.md) | Find refactoring/deepening opportunities informed by `CONTEXT.md` and `docs/adr/`                                          |
| [`jtl-init`](skills/jtl-init/SKILL.md)                                           | First-time setup: CodeGraph index, OpenWolf hooks, `AGENTS.md`/`CLAUDE.md` scaffolding                                     |

## Agents

| Agent                                                      | Role                                                                                                              |
| ---------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| [`deep-explore`](agents/deep-explore.md)                   | Mandatory discovery/context-gathering agent; must run before raw Read/Grep/Glob/`ctx_*`/`codegraph_*` exploration |
| [`planner`](agents/planner.md)                             | Plans and coordinates development work; translates requirements into tasks                                        |
| [`engine-specialist`](agents/engine-specialist.md)         | Implements/refactors application logic, hooks, state management, data flow                                        |
| [`ui-ux-stylist`](agents/ui-ux-stylist.md)                 | Implements visual designs, responsive layout, design-system components, a11y                                      |
| [`code-quality-reviewer`](agents/code-quality-reviewer.md) | Acceptance gate for `task-to-pr` Stage 5 — spec compliance, quality, debt, test suite                             |
| [`tech-debt-reviewer`](agents/tech-debt-reviewer.md)       | Reviews the git diff of changed code for technical debt; updates `_tech-debt.md`                                  |
| [`quiz-taker`](agents/quiz-taker.md)                       | Fresh-context comprehension gate for `teach-back-verification`                                                    |
| [`mcp-fetcher`](agents/mcp-fetcher.md)                     | Cheap read-only fetcher for GitHub issues / Jira tickets                                                          |

## Commands

| Command                                                 | Skill/agent invoked                                                                                                                     |
| ------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| [`/debt-review`](commands/debt-review.md)               | `tech-debt-reviewer` agent — reviews changed code across 9 debt dimensions, appends findings to `_tech-debt.md`, issues a merge verdict |
| [`/resolve-pr-comment`](commands/resolve-pr-comment.md) | `resolve-pr-comment` skill — verifies each PR comment against code, plans fixes, waits for approval, implements, replies                |

## Hooks

[`hooks/hooks.json`](hooks/hooks.json) enforces the context-discipline pattern
for the **main** agent (subagents are exempt — they already run in a disposable
context):

- **`require-deep-explore.sh`** (`PreToolUse`, matches `Read|Grep|Glob`): blocks
  the main agent from reading raw files directly; forces delegation to
  `deep-explore`.
- **`require-deep-explore-agent.sh`** (`PreToolUse`, matches `Agent|Explore`):
  blocks dispatching the built-in `Explore` subagent or an unrelated
  `general-purpose` exploration task (both inherit the expensive main-session
  model); redirects to `deep-explore` (Haiku).
- **`show-subagent-model.sh`** (`PreToolUse`, matches `Agent|Explore`): surfaces
  which model a dispatched subagent will actually run on, resolved from that
  agent's frontmatter.
- **`Stop`**: reminds the user to run `/debt-review` once a task completes.

## Process log

[`proces-log.md`](proces-log.md) is a running transcript log of agent sessions
using this plugin, kept for auditing/debugging the workflow itself.
