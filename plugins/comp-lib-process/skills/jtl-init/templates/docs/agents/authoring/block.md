# Authoring a Block

A Block is a multi-file working unit: a main component plus its sub-parts and
hooks, shipped together as code, declaring the shadcn atoms it depends on. In
Atomic Design terms, an organism.

Author a Block when the [decision matrix](../decision-matrix.md) returns verdict 4
(real logic, state, or accessibility wiring, reused across apps) or verdict 6
(Enhanced Block shadowing a shadcn name).

## Before you build

- Confirm the verdict is Block, not Recipe. Bias toward a Recipe when the logic is
  thin — a Recipe buys flexibility at a consistency cost; a Block buys consistency
  at a maintenance cost.
- **Check a third-party registry first.** Pull instead of build if one fits well.
- New Blocks and any API change go through the spec-first workflow in
  [../contributing.md](../contributing.md). Agree the API before building.

## shadcn type: `registry:block`

- **Atoms** are declared in `registryDependencies` and installed alongside the
  Block by the CLI. Import them from `@/components/ui/*` in the consumer's project.
- **Files** are a flat list of a handful of files, not deep sub-folders.

See [../registry.md](../registry.md) for the item schema and
[../examples/block-structure.md](../examples/block-structure.md) for a reference.

## API

- **Composition while the design is settling.** Start compositional; the code is
  owned by the app developer, so a design change is a rearrangement, not a breaking
  prop change.
- **Property API once it matures.** A Block is the opinionated lane. Once its
  design is proven, graduate to a property API to lock consistency in.
- **Hybrid where one part varies per app.** Keep the property entry point and
  expose a composition slot for the part that genuinely differs (a custom table
  cell, a toolbar action). Prefer a slot over reopening the whole component.
- **Enhanced Block (verdict 6)** keeps its existing property API from day one — its
  design is proven and apps depend on the contract.

## Building it

- **Compose from existing shadcn / JTL pieces.** No raw HTML when a system
  equivalent exists. Do not reimplement behavior that already exists.
- **Tokens only.** See [tokens.md](tokens.md).
- **Slots are passthrough.** Do not hoist child props onto the Block.
- Follow [../api-conventions.md](../api-conventions.md) and the bundled `shadcn`
  skill.

## What ships with it

- JSDoc on the main component and exported props.
- Colocated tests: behavior, keyboard, ARIA, and the status states it claims.
- Stories showing composition and edge cases, not just isolated props.
- Registry metadata with `registryDependencies` and a flat `files` list.

## Self-review

Walk the checklist in [../contributing.md](../contributing.md) and the state /
visual / a11y / edge coverage in [../hardening.md](../hardening.md).
