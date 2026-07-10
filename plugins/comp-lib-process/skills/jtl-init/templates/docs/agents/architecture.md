# Architecture

How the JTL registry is layered and how each item exposes its API.

## Two registries, one stack

The JTL Registry is an extension of the shadcn base registry. They relate two ways:

- **As install sources, peers.** A consuming app lists both registries in
  `components.json`. `shadcn add` pulls base atoms from shadcn and JTL items from
  the JTL Registry.
- **As construction, layered.** Every JTL item builds on shadcn's atom layer. A
  Component wraps one atom; a Block declares its atoms in `registryDependencies`;
  a Recipe composes already-installed items. shadcn ships the full atomic stack;
  JTL ships only what shadcn lacks.

## The layering (Atomic Design)

| Layer     | Atomic Design | What it is                                                            | Built on                | shadcn type                                     |
| --------- | ------------- | --------------------------------------------------------------------- | ----------------------- | ----------------------------------------------- |
| Atom      | atom          | A behavior plus JTL tokens; authored only when shadcn ships none      | Radix or raw DOM        | `registry:ui`                                   |
| Component | molecule      | A thin wrapper on a single atom                                       | one atom                | `registry:component`                            |
| Block     | organism      | A composed feature: several atoms and components with logic and state | the layers below it     | `registry:block`                                |
| Recipe    | (outside)     | The same composition as a Block, assembled into app code per use      | already-installed items | none (docs / `registry:item` / `registry:file`) |

### Atom

JTL's own base unit: one `registry:ui` file, a raw DOM element plus JTL tokens,
shipped only where shadcn has no equivalent (for example `jtl-logo`, `tag`,
`styled-icon`). Rare by design — the ~30 base atoms come straight from shadcn,
themed by tokens. API: variant props, the same shape as a shadcn atom.

### Component

A single, self-contained UI element: one file, one purpose, built on one atom
(shadcn's or a JTL Atom). When neither fits, built directly on the DOM or another
library (for example `cmdk`). Preferably compositional. `registry:ui` when it is a
base atom others build on; `registry:component` for a standalone small piece.

### Block

A multi-file working unit: a main component plus its sub-parts and hooks, shipped
together, declaring the shadcn atoms it depends on in `registryDependencies`. A
flat list of files, not deep sub-folders. Opinionated by design, so it starts
property-shaped or hybrid. The shipped code is owned by the app developer; the
property API exists to reproduce the JTL look with no assembly. Use for surviving
JTL composites (for example an app sidebar, file upload, stepper).

### Recipe

A documented pattern: how to compose already-installed pieces into something,
assembled per use. It can be plain instruction, copy-paste reference code, or
both. What makes it a Recipe is that the result lands in app code, adapted each
time, and is never maintained as a shared JTL unit. There is no `registry:recipe`
type — a Recipe travels as a docs page, a `registry:item` with a `docs` field, or
a markdown file via `registry:file`. Use for things shadcn supplies the atoms for
but ships no packaged whole: ComboBox (popover + command), DatePicker (input +
calendar + popover), Form (compose the field atoms).

A Block and a Recipe are the same idea at two settings: packaged as an installable
unit (Block) or documented as a per-use composition (Recipe). A Block buys
consistency at a maintenance cost; a Recipe buys flexibility at a consistency
cost. **Bias toward a Recipe when the logic is thin.**

## The API shape

Every item ships with one of three shapes.

- **Property API.** One configured entry point driven by props. Buys consistency;
  costs flexibility. Use when the design is proven and stable.
- **Composition API.** The consumer assembles the item from exposed parts. Buys
  flexibility while the design is still moving; costs consistency. Use for new
  components and blocks, and all recipes. This is shadcn's native grain.
- **Hybrid API.** A property entry point that exposes composition slots for the
  parts that genuinely vary per app. Use when a Block has matured but one or two
  parts still differ per app — prefer a slot over reopening the whole component.

### Default and graduation path

This library defaults to **composition over property API**, because it matches
shadcn's grain and both developers and agents meet one familiar interface. The
property API is not dropped — it is the mature end of the path. Once a design is
proven, an item graduates to a property API to lock consistency in, growing hybrid
slots only where per-app variation persists. This works because shadcn's real
change is ownership, not API shape: every item ships as open code the developer
owns either way.

## Related

- [decision-matrix.md](decision-matrix.md) — apply this layering to decide a verdict.
- [api-conventions.md](api-conventions.md) — the concrete naming and prop rules.
- [registry.md](registry.md) — how each type is packaged and published.
