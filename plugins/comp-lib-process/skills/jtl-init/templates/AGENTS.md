# AGENTS.md

Instructions for AI coding agents working in this repository.

## What this repo is

This is the **JTL Component Library** — the authoring and registry repo. It does
not ship a runtime npm package of styled components. Instead it **rebuilds UI on
shadcn atoms and distributes the result through a shadcn registry** as open,
owned code.

Every piece JTL ships is one of four things:

- **Atom** — a JTL-authored base unit (`registry:ui`), only when shadcn ships no
  equivalent. Rare by design.
- **Component** — a thin wrapper on a single atom (`registry:component`). One file,
  one purpose.
- **Block** — a multi-file working unit built on shadcn atoms (`registry:block`),
  declaring its `registryDependencies`. Owned by the consuming app after install.
- **Recipe** — a documented composition of already-installed pieces, assembled
  per use. No install unit; travels as docs, a `registry:item` with a `docs`
  field, or a `registry:file`.

Full definitions and layering: [docs/agents/architecture.md](docs/agents/architecture.md).

## Prime directive

1. **Consume shadcn first.** Base atoms come straight from shadcn, themed by JTL
   tokens. Author a JTL Atom only when shadcn has nothing to consume.
2. **Prefer Recipe / composition over shipping code.** When shadcn supplies the
   parts but no packaged whole and the arrangement varies per use, document a
   Recipe instead of shipping a Block. Bias toward a Recipe when the logic is thin.
3. **Composition is the default API.** It matches shadcn's grain. Graduate to a
   property API only once a design is proven and stable.
4. **Tokens, never raw values.** Every color, spacing, radius, and shadow
   references a JTL token so themes control the visual output.

## Golden paths

| Task                            | Read first                                                               |
| ------------------------------- | ------------------------------------------------------------------------ |
| Decide what form a piece takes  | [docs/agents/decision-matrix.md](docs/agents/decision-matrix.md)         |
| Add or edit a Component         | [docs/agents/authoring/component.md](docs/agents/authoring/component.md) |
| Add or edit a Block             | [docs/agents/authoring/block.md](docs/agents/authoring/block.md)         |
| Author a Recipe                 | [docs/agents/authoring/recipe.md](docs/agents/authoring/recipe.md)       |
| Edit design tokens              | [docs/agents/authoring/tokens.md](docs/agents/authoring/tokens.md)       |
| Publish to the registry         | [docs/agents/registry.md](docs/agents/registry.md)                       |
| Browse / install via MCP        | [docs/agents/mcp.md](docs/agents/mcp.md)                                 |
| Open a change (spec-first + PR) | [docs/agents/contributing.md](docs/agents/contributing.md)               |

## Hard rules

1. **Spec before code for any new Component or Block, or any API change.** File
   an issue, research usage, propose the API. See
   [docs/agents/contributing.md](docs/agents/contributing.md).
2. **Consume shadcn atoms; do not re-author them.** The ~30 base atoms come from
   shadcn, themed by tokens.
3. **No raw HTML when a shadcn/JTL equivalent exists.** Use the system component.
4. **Composition API for new work.** Property API is the mature end of the
   graduation path, not the starting point.
5. **Tokens everywhere.** Replace any raw value with a token reference; tune the
   value in the theme, not the component.
6. **Slots are passthrough.** A parent renders slot content directly and never
   hoists child props onto itself.
7. **Follow the shadcn coding rules.** styling, forms, composition, icons, and
   base-vs-radix are enforced by the bundled `shadcn` skill — do not restate or
   contradict them here.
8. **Every shippable piece has JSDoc, tests, stories, and registry metadata.**

Naming, prop, and accessibility conventions: [docs/agents/api-conventions.md](docs/agents/api-conventions.md).

## Tooling

- **shadcn skill** (bundled in the `comp-lib-process` plugin) — the source of
  truth for styling / forms / composition / icons / base-vs-radix rules and for
  the CLI. Reference it; this repo does not duplicate those rules.
- **shadcn MCP** — browse, search, and install registry items with natural
  language. Setup: [docs/agents/mcp.md](docs/agents/mcp.md).
- **CodeGraph** — structural / flow / blast-radius queries over this repo via
  `codegraph_explore`.
- **OpenWolf** — Claude Code lifecycle hooks (`.wolf/`, `OPENWOLF.md`).

## Documentation map

- [docs/agents/philosophy.md](docs/agents/philosophy.md) — why the system works this way.
- [docs/agents/architecture.md](docs/agents/architecture.md) — Atom / Component / Block / Recipe and API shape.
- [docs/agents/decision-matrix.md](docs/agents/decision-matrix.md) — which form a piece takes.
- [docs/agents/api-conventions.md](docs/agents/api-conventions.md) — naming, props, composition, a11y.
- [docs/agents/authoring/](docs/agents/authoring/) — component, block, recipe, tokens.
- [docs/agents/registry.md](docs/agents/registry.md) — registry.json, item types, publishing.
- [docs/agents/mcp.md](docs/agents/mcp.md) — shadcn MCP.
- [docs/agents/contributing.md](docs/agents/contributing.md) — spec-first workflow and PRs.
- [docs/agents/hardening.md](docs/agents/hardening.md) — the quality pass.
- [docs/agents/maintenance.md](docs/agents/maintenance.md) — ongoing stewardship conventions.
- [docs/agents/decisions/](docs/agents/decisions/) — architecture decision records.
- [docs/agents/examples/](docs/agents/examples/) — recipe, registry-item, and block references.
