---
name: add-plugin
description: Adds a new plugin to the jtl-component-lib-plugin marketplace. Invoke when the user says "add a plugin", "create a new plugin", "register a plugin", or "add a skill as a plugin" to this repo. Handles the plugin folder scaffold, marketplace.json registration, version bumps, optional companion-plugin dependencies, and validation.
user-invocable: true
allowed-tools: Bash(claude plugin *), Bash(mkdir *), Bash(git *)
---

# add-plugin

Adds a new plugin to the `jtl-component-lib-plugin` marketplace. Run every step in order. Do not skip steps.

## Concepts

- **Marketplace** (`.claude-plugin/marketplace.json` at repo root) — lists every installable plugin under `plugins`.
- **Plugin** (`plugins/<name>/`) — a self-contained folder with its own `.claude-plugin/plugin.json` and `skills/`.
- **Companion dependency** — an external plugin (from another marketplace) that a plugin auto-installs via the native `dependencies` field. Cross-marketplace deps require an allowlist entry in the root `marketplace.json`.

---

## Step 1 — Gather Inputs

Ask the user (or infer) before scaffolding:

- **Plugin name** — kebab-case, no spaces (e.g. `comp-lib-process`). Becomes the folder name, the skill namespace, and the `name` in both manifests.
- **Description** — one sentence shown in the marketplace listing.
- **Skills** — which `skills/<skill-name>/SKILL.md` the plugin ships.
- **Companion dependencies** — external plugins this new plugin requires (`name@marketplace`), if any.

---

## Step 2 — Scaffold the Plugin Folder

```bash
NAME=<plugin-name>
mkdir -p "plugins/$NAME/.claude-plugin"
mkdir -p "plugins/$NAME/skills"
```

Create `plugins/$NAME/.claude-plugin/plugin.json`:

```json
{
  "name": "<plugin-name>",
  "version": "1.0.0",
  "description": "<description>",
  "keywords": ["<tag1>", "<tag2>"],
  "author": {
    "name": "Cang Pham",
    "email": "cang.pham@codeleap.de"
  }
}
```

If the plugin has companion dependencies, add a `dependencies` array (see Step 4).

Then add each skill under `plugins/$NAME/skills/<skill-name>/SKILL.md`. Every `SKILL.md` needs `name` and `description` in its YAML frontmatter — the `name` must match its directory name.

---

## Step 3 — Register in the Marketplace

Edit the root `.claude-plugin/marketplace.json` and append an entry to the `plugins` array:

```json
{
  "name": "<plugin-name>",
  "description": "<description>",
  "version": "1.0.0",
  "source": "./plugins/<plugin-name>"
}
```

- `source` is always `./plugins/<plugin-name>`.
- The marketplace-entry `version` should match the plugin's own `version`.

---

## Step 4 — (Only if the plugin has companion dependencies)

Companion plugins that live in **other marketplaces** are declared with the native `dependencies` mechanism. Claude Code auto-installs and auto-enables them on install.

### 4a. Declare dependencies in the plugin manifest

In `plugins/<plugin-name>/.claude-plugin/plugin.json`, add:

```json
"dependencies": [
  { "name": "<dep-name>", "marketplace": "<dep-marketplace>" }
]
```

Use the `name@marketplace` split: for `superpowers@claude-plugins-official`, `name` is `superpowers` and `marketplace` is `claude-plugins-official`.

### 4b. Allowlist cross-marketplace deps in the root marketplace

Cross-marketplace dependencies are **blocked by default**. Add every dependency's marketplace to `allowCrossMarketplaceDependenciesOn` in the root `.claude-plugin/marketplace.json`:

```json
"allowCrossMarketplaceDependenciesOn": [
  "caveman",
  "ponytail",
  "context-mode",
  "claude-plugins-official"
]
```

> On the user's machine, each dependency's marketplace must already be added (`/plugin marketplace add ...`), otherwise the dep shows unresolved in `/doctor` until the marketplace is added.

---

## Step 5 — Bump Versions

Version is the cache key — Claude Code only ships updates when it changes.

- **Always** bump the new/edited plugin's `version` in **both** `plugins/<plugin-name>/.claude-plugin/plugin.json` **and** its marketplace entry (keep them equal).
- **Always** bump the marketplace `metadata.version` in the root `.claude-plugin/marketplace.json`.
- **If the added plugin is a dependency of `comp-lib-process`:**
  - Add it to `comp-lib-process`'s `dependencies` array (Step 4a) and to `allowCrossMarketplaceDependenciesOn` (Step 4b).
  - Bump `comp-lib-process`'s `version` in **both** `plugins/comp-lib-process/.claude-plugin/plugin.json` and its marketplace entry.

Follow semver: MAJOR breaking, MINOR new feature, PATCH fix.

---

## Step 6 — Validate

```bash
claude plugin validate ./plugins/<plugin-name>
```

Must print `✔ Validation passed`. Fix any manifest errors before continuing.

---

## Step 7 — Reload and Verify

```bash
# From a Claude Code session, refresh the marketplace and install
/plugin marketplace update jtl-component-lib-plugin
/plugin install <plugin-name>@jtl-component-lib-plugin
```

If the plugin declares dependencies, the install output lists the auto-installed companions. Confirm they appear.

---

## Checklist (ordered, each step gates the next)

```
[ ] 1. Inputs gathered (name, description, skills, companion deps)
[ ] 2. Plugin folder scaffolded (plugin.json + skills/)
[ ] 3. Registered in root marketplace.json plugins array
[ ] 4. If companion deps: dependencies[] in plugin.json + allowCrossMarketplaceDependenciesOn in marketplace.json
[ ] 5. Versions bumped — plugin (both places) + marketplace metadata; comp-lib-process too if it's a new dep
[ ] 6. `claude plugin validate` passed
[ ] 7. Marketplace reloaded and install verified
```

---

## Hard Rules

- `name` in `plugin.json`, the marketplace entry `name`, and the folder name under `plugins/` must all match.
- `source` is always `./plugins/<plugin-name>` — never `./`.
- Never add a cross-marketplace dependency without also adding its marketplace to `allowCrossMarketplaceDependenciesOn`.
- Every version bump must update **both** the plugin manifest and its marketplace entry — they must stay in sync.
- Bump the root marketplace `metadata.version` on every change so clients pick up the update.
