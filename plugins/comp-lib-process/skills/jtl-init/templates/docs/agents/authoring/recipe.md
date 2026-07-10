# Authoring a Recipe

A Recipe is a documented pattern: how to compose already-installed pieces into
something, assembled per use. It is the library's preferred deliverable whenever
the logic is thin — the [decision matrix](../decision-matrix.md) verdict 2.

What makes it a Recipe: the result lands in app code, adapted each time, and is
never maintained as a shared JTL unit. A Recipe guides a consumer to combine
existing shadcn / JTL components — and external libraries where needed — into a
working whole they own.

## When to write a Recipe

- shadcn supplies the atoms but ships no packaged whole (ComboBox = popover +
  command; DatePicker = input + calendar + popover; Form = the field atoms).
- The composition varies per use, so freezing it as one Block would be wrong.
- The logic is thin enough that consistency is not worth the maintenance cost of a
  Block.

If a second app needs the same arrangement and it stabilizes, promote the Recipe
to a Block. See [../decision-matrix.md](../decision-matrix.md).

## How a Recipe travels

There is no `registry:recipe` type. Pick the lightest vehicle that fits:

- **A docs page** — plain instruction plus copy-paste reference code. The
  canonical shape (see shadcn's React Hook Form guide): no install, just a page of
  code wiring the already-installed atoms together, which the developer copies and
  adapts.
- **A `registry:item` with a `docs` field** — when the Recipe benefits from being
  discoverable through the CLI / MCP alongside the pieces it composes.
- **A `registry:file`** (for example a markdown file) — when the Recipe should be
  installed into the consumer's repo as guidance next to their code.

See [../registry.md](../registry.md) for the schema of each vehicle.

## What a good Recipe contains

1. **Intent** — what the consumer is building and when to reach for this Recipe.
2. **Prerequisites** — the shadcn / JTL items to install first (with the
   `shadcn add` commands) and any external library, with why it is needed.
3. **Composition** — copy-paste reference code that wires the installed pieces
   together, using JTL tokens and the conventions in
   [../api-conventions.md](../api-conventions.md).
4. **Adaptation points** — what the consumer is expected to change per use, and
   what to leave alone.
5. **Accessibility notes** — labels, focus, and ARIA the composition must preserve.
6. **Promotion note** — a one-line pointer to the Block it would become if it
   stabilizes across apps.

## Rules

- **Composition API only.** A Recipe is assembled in app code; it never ships a
  closed prop surface.
- **Tokens, never raw values**, in all reference code. See [tokens.md](tokens.md).
- **Reuse existing pieces.** Do not hand-write markup a shadcn / JTL component
  already provides.
- **Name external libraries explicitly** and pin the reason, so a consumer can
  judge the dependency.

## Example

See [../examples/recipe-combobox.md](../examples/recipe-combobox.md) for a worked
Recipe (ComboBox composed from popover + command).
