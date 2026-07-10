# Registry

How JTL items are packaged and published through a shadcn registry. Reference:
<https://ui.shadcn.com/docs/registry> and <https://ui.shadcn.com/docs/registry/examples>.

## The two files

- **`registry.json`** — the registry manifest listing every item.
- **`registry-item.json`** — the schema for a single item. Each item declares
  `$schema`, `name`, `type`, and `files`, plus optional `dependencies`,
  `registryDependencies`, `cssVars`, `css`, `meta`, and more.

## Item types

| Type                 | Use for                                              | Lands in             |
| -------------------- | ---------------------------------------------------- | -------------------- |
| `registry:ui`        | A JTL Atom or base UI component                      | `components/ui/`     |
| `registry:component` | A standalone small Component                         | `components/`        |
| `registry:block`     | A multi-file Block                                   | per `files[].target` |
| `registry:lib`       | Shared helpers / constants                           | `lib/`               |
| `registry:hook`      | A React hook                                         | `hooks/`             |
| `registry:file`      | An arbitrary file (for example a Recipe as markdown) | per `target`         |
| `registry:style`     | A style that extends or replaces shadcn              | project-wide         |
| `registry:theme`     | A token theme (`cssVars`)                            | project-wide         |
| `registry:base`      | A complete design-system base (`config` + tokens)    | project-wide         |
| `registry:item`      | A generic item (universal / mixed files)             | per `target`         |
| `registry:font`      | A Google Font (`font` field)                         | project-wide         |

## Key fields

- **`registryDependencies`** — other items to install first. Names resolve within
  the configured registries; full URLs pull from a remote registry. A Block lists
  its shadcn atoms here.
- **`dependencies` / `devDependencies`** — npm packages to install.
- **`files[]`** — each with `path`, `type`, `content`, and an optional `target`.
- **Target placeholders** — `@components/`, `@ui/`, `@lib/`, `@hooks/` resolve from
  the consumer's `components.json`, so the same item works across alias setups.
  Anything after the placeholder is preserved (`@ui/ai/prompt-input.tsx`).
- **`cssVars`** — theme variables (`theme`, `light`, `dark`).
- **`css`** — custom `@layer`, `@utility`, `@import`, `@plugin`, `@keyframes`.
- **`meta`** — arbitrary metadata for tooling (for example `category`, `version`).
- **`envVars`** — development / example env vars only. Never production secrets.

## Recipes in the registry

A Recipe has no dedicated type. Ship it as:

- a docs page (outside the registry), or
- a `registry:item` with a `docs` field, or
- a `registry:file` markdown installed into the consumer's repo.

See [authoring/recipe.md](authoring/recipe.md).

## Consumer configuration

A consuming app adds the JTL registry to `components.json`:

```json
{
  "registries": {
    "@jtl": "https://registry.jtl-software.com/{name}.json"
  }
}
```

Private registries add headers referencing env vars for authentication; see the
shadcn authentication docs.

## Publishing checklist

- Item `type` matches the [decision-matrix](decision-matrix.md) verdict.
- `registryDependencies` list every shadcn atom the item imports.
- `cssVars` cover the tokens the item introduces; no raw values in `files`.
- `meta` records category and version where the tooling expects them.
- The item installs cleanly with `shadcn add` into a fresh app.

## Examples

See [examples/registry-item.md](examples/registry-item.md).
