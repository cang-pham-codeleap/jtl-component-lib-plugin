# Hardening

The quality pass after a piece is built and merged. Hardening asks: is this
correct, complete, and polished? It makes the library consistent with itself — not
with any external reference.

## What hardening is and is not

- **Is:** fixing bugs, closing state-coverage gaps, tightening visual quality,
  and surfacing design decisions for human review.
- **Is not:** adding features, matching an external system, or system-level design
  changes. Those route back to the spec workflow in
  [contributing.md](contributing.md).

### The scope test

Ask: does the piece's existing API already promise this behavior?

| Situation                                                                   | Route                           |
| --------------------------------------------------------------------------- | ------------------------------- |
| `isDisabled` exists but looks identical to default                          | Hardening — the API promises it |
| A family contract says inputs have `startIcon` but one is missing it        | Hardening — consistency gap     |
| Tokens say `success` / `error` but a component says `positive` / `negative` | Hardening — self-consistency    |
| A component has no loading concept and you want to add `isLoading`          | Spec workflow — new capability  |
| "An external system has feature X"                                          | Spec workflow — feature parity  |

## Layer 1: automated audit (objective, pass/fail)

- **Tokens** — no hardcoded colors, shadows, spacing, radii, or typography.
- **Component reuse** — close buttons use `Button`, dividers use `Separator`,
  icons come from the registry.
- **Prop naming** — `is` / `has` booleans, `on{Verb}` callbacks, `default`
  prefixes.
- **Type naming** — `<Component>Props`, `<Component>Variant`, `<Component>Context`.
- **Structure** — `displayName` set, file present in the registry, correct exports.
- **Input consistency** — `label`, `value`, `onChange` / `onChangeAction`, status
  shape `{ type, message? }`.
- **Accessibility contracts** — `label` on interactive pieces, ARIA wiring,
  `isDisabled` maps to `disabled`, busy uses `aria-busy`.

## Layer 2: bug and visual fixes (clear right answer)

Every state the piece claims to support must render correctly:

- Rest, hover (with a hover-capable guard), focus-visible, active / pressed.
- Disabled (muted, non-interactive, correct ARIA), loading (spinner / skeleton,
  interaction blocked, stable dimensions).
- Error / warning / success if `status` exists; selected if selectable.
- Empty (no collapse) and overflow (truncate or wrap, no breakage).

Also: light and dark mode, all themes, token adherence, family consistency,
keyboard nav, screen-reader roles and labels, WCAG AA contrast, and edge cases
(long content, empty, single item, rapid interaction, constrained containers).

## Layer 3: design review (human judgment)

Proportions, interaction feel, density, and composition quality inside Dialog,
Table, Card, and layout. A human evaluates these; naming and API shape are not
part of Layer 3 — they route to the spec workflow.

## Routing findings

| Finding                               | Route                                                    |
| ------------------------------------- | -------------------------------------------------------- |
| Wrong token, visual bug, broken state | Hardening — fix it                                       |
| Family consistency gap                | Hardening — the system already decided                   |
| New prop, variant, or sub-component   | Spec workflow                                            |
| Naming dispute with no clear answer   | Flag it; evaluate; file a spec issue if a winner emerges |

## Related

- [maintenance.md](maintenance.md) — the ongoing audit that enforces Layer 1 continuously.
- [api-conventions.md](api-conventions.md) — the conventions being checked.
