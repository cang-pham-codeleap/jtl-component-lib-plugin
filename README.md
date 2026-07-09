# jtl-component-lib-plugin

AI coding agent plugin for the JTL component library project. Provides curated skills for component library workflows and is designed to be installed as a plugin in [CL-AI-Toolbox](https://github.com/CODE-LEAP-AG/CL-AI-Toolbox).

## Installation

### Standalone (Claude Code)

```bash
# Register this plugin
/plugin install <path-or-url-to-this-repo>
```

On first session start, the hook automatically installs required companion plugins: `caveman`, `ponytail`, `context-mode`, and `superpowers`.

### Via CL-AI-Toolbox

```bash
/plugin marketplace add CODE-LEAP-AG/CL-AI-Toolbox
/plugin install jtl-component-lib@cl-ai-toolbox
```

## Available Skills

| Invoke | What it does |
|---|---|
| `/create-pr` | Full PR creation workflow for `jtl-platform-ui-react` — version bump, changelog, draft PR via `gh` CLI |
| *(auto)* `shadcn` | shadcn/ui component management — add, search, fix, style, compose |

> `shadcn` is context-aware and triggers automatically when working with shadcn projects. `create-pr` is user-invocable.

## Structure

```
.claude-plugin/
  plugin.json        ← plugin metadata + SessionStart hook
  marketplace.json   ← CL-AI-Toolbox registry entry
plugins/
  comp-lib-process/
    deps.json        ← required companion plugins
    hooks/
      ensure-deps.js ← auto-installs companions on session start
    skills/
      create-pr/     ← PR automation skill
      shadcn/        ← shadcn/ui skill + rules + context
```

## Required Companions

Installed automatically by the `SessionStart` hook:

| Plugin | Purpose |
|---|---|
| `caveman` | Token-efficient communication mode |
| `ponytail` | Agent memory |
| `context-mode` | Context management |
| `superpowers` | Skill discovery and invocation |

## Contributing

Target the `dev` branch. Fill in all PR template sections. Skills live in `skills/<name>/SKILL.md`.

