# jtl-component-lib-plugin

AI coding agent plugin for the JTL component library project. Provides curated skills for component library workflows and is designed to be installed as a plugin in [CL-AI-Toolbox](https://github.com/CODE-LEAP-AG/CL-AI-Toolbox).

## Installation

### Standalone (Claude Code)

```bash
# 1. Register the marketplace (one-time per machine)
/plugin marketplace add cang-pham-codeleap/jtl-component-lib-plugin

# 2. Install the plugin
/plugin install comp-lib-process@jtl-component-lib-plugin
```

On first session start, the hook automatically installs required companion plugins: `caveman`, `ponytail`, `context-mode`, and `superpowers`.

## First-time Setup — Run `jtl-init`

> **Before starting any task, run the `jtl-init` skill** to wire up the tools and
> agent docs your project needs:

```
/jtl-init
```

This installs and configures:

### CodeGraph

[CodeGraph](https://github.com/colbymchenry/codegraph) is a pre-built local code knowledge graph for your codebase. Instead of the agent crawling files one-by-one with grep/Read/Glob, it asks a single `codegraph_explore` query and gets back the exact source, call paths, and blast radius in one shot.

- **58% fewer tool calls** · **22% faster answers** · **~zero file reads** (benchmarked across 7 real-world codebases)
- Builds a local SQLite index of every symbol, call edge, and dependency
- 100% local — no data leaves your machine, no API keys

**Auto-sync — no hook required.** CodeGraph's MCP server process (kept alive by Claude Code) embeds a native OS file watcher (FSEvents on macOS, inotify on Linux). Every time a source file changes — whether the agent edits it or you do — the watcher fires, debounces for 2 seconds, and incrementally updates the graph. There is nothing to re-run and no separate sync hook needed; the index is always current as long as the MCP server is running.

`jtl-init` installs the CLI, runs `codegraph init` to build the initial project index, and connects it to your Claude Code session. After that, updates are automatic.

### OpenWolf

[OpenWolf](https://www.npmjs.com/package/openwolf) (`npm install -g openwolf`) registers Claude Code lifecycle hooks and writes an `OPENWOLF.md` instruction file into your project. Running `openwolf init` creates the `.wolf/` directory with hooks that fire on every agent action — enforcing project-specific rules and keeping the agent on-rails throughout the session.

`jtl-init` installs the CLI and runs `openwolf init` in your project root.

### Agent docs (`AGENTS.md` + `docs/agents/`)

`jtl-init` scaffolds a set of agent instructions into the project so any AI agent
knows this is a shadcn-based component library that ships Components, Blocks, and
Recipes through a shadcn registry:

- **`AGENTS.md`** — the repo-root entry point: what the repo is, the prime
  directive (consume shadcn first, prefer Recipe/composition, tokens everywhere),
  golden paths, and hard rules.
- **`CLAUDE.md`** — a thin file that references `AGENTS.md` so Claude Code picks it
  up automatically.
- **`docs/agents/`** — the conventions folder: philosophy, architecture
  (Atom/Component/Block/Recipe), decision matrix, API conventions, authoring
  guides (component, block, recipe, tokens), registry, MCP, contributing,
  hardening, maintenance, decision records, and examples.

A bundled `scaffold-agent-docs.sh` script does the work in one run. It is
**idempotent** and never overwrites your content: it only creates missing files
and appends a `docs/agents/` reference to an existing `AGENTS.md`, or an
`AGENTS.md` reference to an existing `CLAUDE.md`. Re-running `jtl-init` is safe —
it fills in anything missing and leaves everything else untouched.

The shadcn coding rules (styling, forms, composition, icons) are **not** copied
into your repo; the agent docs reference the `shadcn` skill and the shadcn MCP so
they stay in sync.

---

## What This Plugin Enforces

Installing `comp-lib-process` changes how the agent behaves in two ways that are **always on**:

### 1. Forced `deep-explore` for all exploration

Two PreToolUse hooks prevent the main agent from reading raw files directly:

- **`require-deep-explore.sh`** — blocks `Read`, `Grep`, `Glob`, and raw Bash exploration on source files from the main agent. The agent must delegate to `deep-explore` instead.
- **`require-deep-explore-agent.sh`** — blocks the built-in `Explore` subagent (which runs on the expensive main model) and redirects it to the `deep-explore` agent running on Haiku.

**Why:** Without this gate, the agent does a slow file-by-file crawl dumping 40k–130k tokens of raw file content into context. With `deep-explore` + CodeGraph, it makes one `codegraph_explore` call and gets back compressed, actionable findings — same information, a fraction of the cost.

**What you'll notice:** At the start of any task involving codebase exploration, the agent spawns a `deep-explore` subagent (Haiku) that returns a concise summary. The main agent works from that summary instead of raw files.

### 2. `/debt-review` — post-task technical debt check

After completing any feature, fix, or refactor, run:

```
/debt-review
```

This triggers the `tech-debt-reviewer` subagent to analyze only the git diff of changed files across 9 dimensions (architecture, code quality, test debt, types, error handling, security, performance, dependency health, documentation). It outputs a structured report, appends Critical/High items to `_tech-debt.md`, and issues a merge verdict:

| Verdict            | Meaning                             |
| ------------------ | ----------------------------------- |
| ✅ CLEAN           | Safe to merge                       |
| ⚠️ NEEDS ATTENTION | Merge with known debt logged        |
| 🚫 BLOCK           | Critical issues must be fixed first |

Options: `--scope staged`, `--scope last-commit`, `--focus security`

---

## Available Skills

| Invoke            | What it does                                                                                           |
| ----------------- | ------------------------------------------------------------------------------------------------------ |
| `/jtl-init`       | First-time setup: installs CodeGraph + OpenWolf and scaffolds the `AGENTS.md` + `docs/agents/` docs    |
| `/create-pr`      | Full PR creation workflow for `jtl-platform-ui-react` — version bump, changelog, draft PR via `gh` CLI |
| `/debt-review`    | Post-task technical debt review on changed files — structured report + merge verdict                   |
| _(auto)_ `shadcn` | shadcn/ui component management — add, search, fix, style, compose                                      |

> `shadcn` is context-aware and triggers automatically when working with shadcn projects. `create-pr` and `debt-review` are user-invocable.

## Structure

```
.claude-plugin/
  plugin.json        ← plugin metadata + SessionStart hook
  marketplace.json   ← CL-AI-Toolbox registry entry
plugins/
  comp-lib-process/
    deps.json        ← required companion plugins
    hooks/
      ensure-deps.js            ← auto-installs companions on session start
      require-deep-explore.sh   ← blocks raw file reads from main agent
      require-deep-explore-agent.sh ← redirects Explore subagent to deep-explore
    agents/
      deep-explore.md   ← Haiku discovery agent (codegraph + context-mode)
      tech-debt-reviewer.md ← Sonnet debt analysis agent
    commands/
      debt-review.md    ← /debt-review slash command
    skills/
      jtl-init/     ← CodeGraph + OpenWolf setup + agent-docs scaffold
        scaffold-agent-docs.sh ← idempotent AGENTS.md + docs/agents/ generator
        templates/             ← AGENTS.md, CLAUDE.md, docs/agents/* sources
      create-pr/    ← PR automation skill
      shadcn/       ← shadcn/ui skill + rules + context
```

## Required Companions

Installed automatically by the `SessionStart` hook:

| Plugin         | Purpose                                                             |
| -------------- | ------------------------------------------------------------------- |
| `caveman`      | Token-efficient communication mode                                  |
| `ponytail`     | Enforces a "lazy senior dev" philosophy—cuts over-engineering/bloat |
| `context-mode` | Context management                                                  |
| `superpowers`  | Skill discovery and invocation                                      |

## Contributing

Target the `dev` branch. Fill in all PR template sections. Skills live in `plugins/comp-lib-process/skills/<name>/SKILL.md`.
