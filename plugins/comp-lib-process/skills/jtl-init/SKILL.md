---
name: jtl-init
description: Sets up the working environment for a JTL Component Library project by wiring up three things — CodeGraph (installs the CLI and builds the local knowledge graph index so the bundled `codegraph` MCP server can answer structural / flow / blast-radius queries), OpenWolf (installs the CLI and runs its native `openwolf init` to create the `.wolf/` hooks and OPENWOLF.md instructions), and the JTL agent docs (scaffolds `AGENTS.md`, `CLAUDE.md`, and the `docs/agents/` conventions folder in the repo). Invoke when the user says "jtl init", "set up the JTL project", "set up my environment", "initialize codegraph", "install openwolf", "index this repo", "create the hooks", "scaffold agent docs", "create AGENTS.md", or opens a fresh JTL workspace that has no `.codegraph/`, `.wolf/`, or `AGENTS.md` yet.
user-invocable: true
allowed-tools: Bash(command -v *), Bash(codegraph *), Bash(openwolf *), Bash(npm *), Bash(curl *), Bash(irm *), Bash(bash *), Bash(ls *)
---

# jtl-init

Prepares the current workspace for JTL development by setting up three things in
the project:

1. **CodeGraph** — a local code knowledge graph. The bundled `codegraph` MCP
   server answers structural / flow / blast-radius queries with `codegraph_explore`.
2. **OpenWolf** — its native CLI writes Claude Code lifecycle hooks and an
   `OPENWOLF.md` instruction file into the project.
3. **Agent docs** — scaffolds `AGENTS.md`, `CLAUDE.md`, and the `docs/agents/`
   conventions folder so agents know this is a shadcn-based component library that
   ships Components, Blocks, and Recipes through a shadcn registry.

Run every step in order from the workspace root. Stop and report if any step fails.

## Options

- `--force` — re-index CodeGraph from scratch (rebuild the graph even if
  `.codegraph/` exists).

---

## Part A — CodeGraph

### Step A1 — Verify the CodeGraph CLI is installed

```bash
command -v codegraph
```

- If it resolves, continue to Step A2.
- If it is NOT found, install it, then re-run `command -v codegraph` to confirm it
  is on PATH before continuing:
  - macOS / Linux:
    ```bash
    curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh
    ```
  - Windows (PowerShell):
    ```powershell
    irm https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.ps1 | iex
    ```

### Step A2 — Initialize + index the project

- Default: build the graph in one step (creates `.codegraph/`).
  ```bash
  codegraph init
  ```
- If the user passed `--force` and `.codegraph/` already exists, rebuild instead:
  ```bash
  codegraph index --force
  ```

### Step A3 — Verify the index

```bash
codegraph status
```

Report the node / edge / file counts so the user can confirm the graph built
correctly.

---

## Part B — OpenWolf

OpenWolf requires Node.js 20+ and the Claude Code CLI.

### Step B1 — Verify the OpenWolf CLI is installed

```bash
command -v openwolf
```

- If it resolves, continue to Step B2.
- If it is NOT found, install it globally, then re-run `command -v openwolf` to
  confirm it is on PATH before continuing:
  ```bash
  npm install -g openwolf
  ```

### Step B2 — Create the hooks and instructions

Run OpenWolf's native init to register the Claude Code lifecycle hooks and write
the instruction files into the consumer project. This creates the `.wolf/`
directory (including `hooks/` and `OPENWOLF.md`):

```bash
openwolf init
```

### Step B3 — Verify OpenWolf

```bash
openwolf status
```

Report the health / stats so the user can confirm the hooks registered and the
`.wolf/` files were created.

---

## Part C — Agent docs

Scaffold the JTL agent documentation into the project by running the bundled
`scaffold-agent-docs.sh` script. The script lives next to this `SKILL.md`; resolve
`<skill_dir>` to that skill directory.

The script creates:

- `AGENTS.md` — the entry point at the repo root.
- `CLAUDE.md` — a thin file that references `AGENTS.md`.
- `docs/agents/` — the conventions folder (philosophy, architecture,
  decision-matrix, api-conventions, authoring, registry, mcp, contributing,
  hardening, maintenance, decisions, examples).

Run it from the workspace root:

```bash
bash "<skill_dir>/scaffold-agent-docs.sh"
```

The script is **idempotent** and never overwrites existing content: it only
creates missing files and appends a missing `docs/agents/` reference to an
existing `AGENTS.md` or a missing `AGENTS.md` reference to an existing `CLAUDE.md`.
It prints one line per file plus a final `created=.. updated=.. skipped=..`
summary — report that summary to the user.

To scaffold into a directory other than the current one, pass it as an argument:
`bash "<skill_dir>/scaffold-agent-docs.sh" /path/to/repo`.

---

## Step D — Remind the user

Tell the user to reload the VS Code window (or restart the agent) so:

- the `codegraph` MCP server connects to the freshly built index, and
- the OpenWolf hooks and `OPENWOLF.md` instructions take effect.

CodeGraph auto-sync then keeps the graph current on every file change, and
OpenWolf's hooks fire on every Claude action — no need to re-run this skill. The
agent docs in `AGENTS.md` and `docs/agents/` are now in place; re-running this
skill will not overwrite them, only fill in anything missing.
