# Example registry items

Reference `registry-item.json` shapes for JTL items. Full schema and field
reference: [../registry.md](../registry.md).

## Component (`registry:component`)

```json
{
  "$schema": "https://ui.shadcn.com/schema/registry-item.json",
  "name": "tag",
  "type": "registry:component",
  "author": "JTL",
  "meta": { "category": "display", "version": "1.0.0" },
  "files": [
    {
      "path": "components/tag.tsx",
      "type": "registry:component",
      "content": "..."
    }
  ]
}
```

## Block (`registry:block`)

Declares its shadcn atoms in `registryDependencies`; ships a flat list of files.

```json
{
  "$schema": "https://ui.shadcn.com/schema/registry-item.json",
  "name": "app-sidebar",
  "type": "registry:block",
  "description": "The JTL application sidebar.",
  "registryDependencies": [
    "sidebar",
    "separator",
    "collapsible",
    "dropdown-menu",
    "avatar"
  ],
  "files": [
    {
      "path": "blocks/app-sidebar/app-sidebar.tsx",
      "type": "registry:component",
      "content": "..."
    },
    {
      "path": "blocks/app-sidebar/nav-main.tsx",
      "type": "registry:component",
      "content": "..."
    },
    {
      "path": "blocks/app-sidebar/nav-user.tsx",
      "type": "registry:component",
      "content": "..."
    }
  ]
}
```

## Recipe as an installable file (`registry:file`)

A Recipe can be installed into the consumer's repo as guidance next to their code.

```json
{
  "$schema": "https://ui.shadcn.com/schema/registry-item.json",
  "name": "combo-box-recipe",
  "type": "registry:item",
  "docs": "Compose a ComboBox from popover + command. See the JTL registry docs.",
  "registryDependencies": ["popover", "command", "button"],
  "files": [
    {
      "path": "docs/combo-box.md",
      "type": "registry:file",
      "target": "~/docs/recipes/combo-box.md",
      "content": "..."
    }
  ]
}
```

## Theme tokens (`registry:theme`)

Tokens as `cssVars`, with light and dark values.

```json
{
  "$schema": "https://ui.shadcn.com/schema/registry-item.json",
  "name": "jtl-theme",
  "type": "registry:theme",
  "cssVars": {
    "light": { "brand": "oklch(0.55 0.2 255)" },
    "dark": { "brand": "oklch(0.7 0.16 255)" }
  }
}
```
