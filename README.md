# jtl-component-lib-plugin

AI coding agent plugin for the JTL component library project. Provides curated skills for component library workflows and is designed to be installed as a plugin in [CL-AI-Toolbox](https://github.com/CODE-LEAP-AG/CL-AI-Toolbox).

## Installation

### GitHub Copilot (APM)

Use [APM](https://github.com/microsoft/apm) to install the portable skill
collection for Copilot local agent mode. Commit the generated `apm.lock.yaml`
to consumer projects so installations are reproducible.

```bash
# One-time: install APM on macOS/Linux
curl -fsSL https://aka.ms/apm-unix | sh

# Install the JTL skills for the Copilot target
apm install cang-pham-codeleap/jtl-component-lib-plugin -t copilot
apm compile -t copilot
```

`task-to-pr` requires Superpowers for FULL-tier design and planning:

```bash
copilot plugin marketplace add obra/superpowers-marketplace
copilot plugin install superpowers@superpowers-marketplace
```

APM deploys skills to `.agents/skills/`, generates `AGENTS.md`, and adopts
portable instructions under `.github/instructions/`; GitHub Copilot coding
agent reads all three locations.
For Copilot coding agent, configure optional repository MCP servers separately
in GitHub repository Settings because APM cannot configure GitHub-hosted agent
MCP settings. Make the repository's **Validate Cross-Harness Support** workflow
a required branch-protection check before merge.

### Prerequisite — Register the required marketplaces

`comp-lib-process` depends on plugins hosted in other marketplaces. Claude Code
only auto-installs those dependencies from marketplaces it already knows about —
a plugin cannot add a marketplace on its own. **Before installing the plugin,
register all required marketplaces once.**

Add the following to your project's `.claude/settings.json` (create the file if it
doesn't exist). When you trust the folder, Claude Code registers these
marketplaces automatically, then resolves and installs `comp-lib-process` and its
dependencies:

```jsonc
{
  "extraKnownMarketplaces": {
    "caveman": {
      "source": { "source": "github", "repo": "juliusbrussee/caveman" },
    },
    "ponytail": {
      "source": { "source": "github", "repo": "DietrichGebert/ponytail" },
    },
    "context-mode": {
      "source": { "source": "github", "repo": "mksglu/context-mode" },
    },
    "superpowers-marketplace": {
      "source": { "source": "github", "repo": "obra/superpowers-marketplace" },
    },
    "jtl-component-lib-plugin": {
      "source": {
        "source": "github",
        "repo": "cang-pham-codeleap/jtl-component-lib-plugin",
      },
    },
  },
  "enabledPlugins": {
    "comp-lib-process@jtl-component-lib-plugin": true,
  },
}
```

> Replace each `OWNER/…-repo` with the real git source for that marketplace.

Alternatively, register them from the CLI (one-time per machine):

```bash
claude plugin marketplace add juliusbrussee/caveman
claude plugin marketplace add DietrichGebert/ponytail
claude plugin marketplace add mksglu/context-mode
```

### Standalone (Claude Code)

```bash
# 1. Register the marketplace (one-time per machine)
/plugin marketplace add cang-pham-codeleap/jtl-component-lib-plugin

# 2. Install the plugin
/plugin install comp-lib-process@jtl-component-lib-plugin
```

Once the required marketplaces above are registered, Claude Code automatically
installs the companion plugins declared as dependencies: `caveman`, `ponytail`,
`context-mode`, and `superpowers`.

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

## Subagent model routing

Each dispatched subagent (`deep-explore`, `planner`, `engine-specialist`,
`ui-ux-stylist`, `code-quality-reviewer`, `quiz-taker`, `tech-debt-reviewer`,
`mcp-fetcher`) pins a prioritized `model:` array (primary + fallback) in its
own frontmatter, matched to what the role actually needs — cheap, mechanical
roles (fetch, quiz, discovery) stay off the expensive coordinator model by
default instead of silently inheriting it.

See [`model-routing.md`](plugins/comp-lib-process/skills/task-to-pr/references/model-routing.md)
for the full routing table and rationale — it's the single source of truth;
don't fork the table into other docs.

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
    hooks/
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

Installed through Claude Code's native plugin dependency manifest:

| Plugin         | Purpose                                                             |
| -------------- | ------------------------------------------------------------------- |
| `caveman`      | Token-efficient communication mode                                  |
| `ponytail`     | Enforces a "lazy senior dev" philosophy—cuts over-engineering/bloat |
| `context-mode` | Context management                                                  |
| `superpowers`  | Skill discovery and invocation                                      |

## Contributing

Target the `main` branch. Fill in all PR template sections. Skills live in `plugins/comp-lib-process/skills/<name>/SKILL.md`.
