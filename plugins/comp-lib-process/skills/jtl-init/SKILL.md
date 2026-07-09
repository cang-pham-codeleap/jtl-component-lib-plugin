---
name: jtl-init
description: Sets up the working environment for a JTL consumer project by wiring up two tools — CodeGraph (installs the CLI and builds the local knowledge graph index so the bundled `codegraph` MCP server can answer structural / flow / blast-radius queries) and OpenWolf (installs the CLI and runs its native `openwolf init` to create the `.wolf/` hooks and OPENWOLF.md instructions in the consumer project). Invoke when the user says "jtl init", "set up the JTL project", "set up my environment", "initialize codegraph", "install openwolf", "index this repo", "create the hooks", or opens a fresh JTL workspace that has no `.codegraph/` or `.wolf/` yet.
user-invocable: true
allowed-tools: Bash(command -v *), Bash(codegraph *), Bash(openwolf *), Bash(npm *), Bash(curl *), Bash(irm *)
---

# jtl-init

Prepares the current workspace for JTL development by setting up two tools in the
consumer project:

1. **CodeGraph** — a local code knowledge graph. The bundled `codegraph` MCP
   server answers structural / flow / blast-radius queries with `codegraph_explore`.
2. **OpenWolf** — its native CLI writes Claude Code lifecycle hooks and an
   `OPENWOLF.md` instruction file into the consumer project.

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

## Step C — Remind the user

Tell the user to reload the VS Code window (or restart the agent) so:

- the `codegraph` MCP server connects to the freshly built index, and
- the OpenWolf hooks and `OPENWOLF.md` instructions take effect.

CodeGraph auto-sync then keeps the graph current on every file change, and
OpenWolf's hooks fire on every Claude action — no need to re-run this skill.
