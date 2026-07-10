# shadcn MCP

The shadcn MCP server lets an agent browse, search, and install registry items
with natural language. Reference: <https://ui.shadcn.com/docs/mcp>.

For the shadcn CLI and the styling / forms / composition / icons coding rules, use
the bundled `shadcn` skill — this page only covers MCP setup and usage.

## What it does

- **Browse** — list components, blocks, and items from any configured registry.
- **Search** — find items by name or functionality across registries.
- **Install** — add items with conversational prompts.
- **Namespaces** — access multiple registries via `@namespace` syntax.

## Setup

Configure the server for your client, then restart it.

Claude Code (`.mcp.json`) or Cursor (`.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "shadcn": { "command": "npx", "args": ["shadcn@latest", "mcp"] }
  }
}
```

VS Code (`.vscode/mcp.json`):

```json
{
  "servers": {
    "shadcn": { "command": "npx", "args": ["shadcn@latest", "mcp"] }
  }
}
```

## Registries

The standard shadcn registry needs no configuration. Add the JTL registry (and any
private one) in `components.json`:

```json
{
  "registries": {
    "@jtl": "https://registry.jtl-software.com/{name}.json"
  }
}
```

For private registries, set the token in `.env.local` and reference it from the
registry `headers`. See the shadcn authentication docs.

## Example prompts

- "Show me all available components in the JTL registry."
- "Find a combo-box in the JTL registry."
- "Install `@jtl/app-sidebar` into this project."
- "Build a settings page using components from the JTL registry."

## Related

- [registry.md](registry.md) — item types and `components.json` configuration.
- The bundled `shadcn` skill — CLI usage and coding rules.
