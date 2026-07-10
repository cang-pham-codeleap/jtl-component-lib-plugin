# Authoring a Component

A Component is a single, self-contained UI element: one file, one purpose, a thin
wrapper on a single atom. In Atomic Design terms, a molecule.

Author a Component only when the [decision matrix](../decision-matrix.md) returns
verdict 3 (JTL-only, small enough for one file). If shadcn already covers it with
no JTL logic, consume the shadcn atom instead.

## Before you build

- Confirm the verdict is Component, not Recipe or Block.
- New Components go through the spec-first workflow in
  [../contributing.md](../contributing.md). File an issue and agree the API first.

## shadcn type

- `registry:ui` when it is a base atom other pieces build on (lands in
  `components/ui/`).
- `registry:component` for a standalone small piece (lands in `components/`).

## Building it

- **Build on one atom** — a shadcn atom or a JTL Atom. When neither fits, build on
  the DOM or a focused library (for example `cmdk`).
- **Prefer composition.** Expose parts rather than a wide prop surface. A property
  API is earned later (see [../architecture.md](../architecture.md)).
- **Tokens only.** No raw colors, spacing, radii, or shadows. See
  [tokens.md](tokens.md).
- **Follow the shadcn coding rules** (styling, icons, composition) from the
  bundled `shadcn` skill, and the naming / prop rules in
  [../api-conventions.md](../api-conventions.md).

## What ships with it

- **JSDoc** on the component and every exported prop, with an `@example`.
- **Colocated tests** — behavior, keyboard, ARIA.
- **Stories** demonstrating each applicable state, not just enumerating props.
- **Registry metadata** — the item entry with its type and files. See
  [../registry.md](../registry.md).

## Self-review

Before opening the PR, walk the checklist in [../contributing.md](../contributing.md)
and the state coverage in [../hardening.md](../hardening.md).
