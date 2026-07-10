# Editing Design Tokens

Tokens are the design contract. Visuals live in themeable tokens; structure lives
in components. This separation lets designers tune visuals without risking
behavioral regressions.

## The rule

**Every visual value in a component references a token.** Colors, spacing, sizing,
line heights, radii, and shadows resolve through a token, and the theme decides
what that token resolves to.

If you find a raw value in a component (a hardcoded pixel, a hex color, a numeric
line height), the fix is to **replace it with a token reference** — not to swap it
for a different raw value. Then tune the value in the theme.

## Theme vs core: where does a change go?

| Change                                | Where                                              | Why                                                |
| ------------------------------------- | -------------------------------------------------- | -------------------------------------------------- |
| "This grey should be darker"          | Theme — adjust the token value                     | The component already references the right token   |
| "Corners should be rounder"           | Theme — adjust the radius token                    | What the token means is a theme decision           |
| "Use a different grey than body text" | Core — change which token the component references | Token selection is a structural decision           |
| "Add a compact variant"               | Core — new variant, new prop                       | Variants are structural                            |
| "This needs a hover state"            | Core — new behavior                                | Interaction states are behavior, not visual tuning |

Key principle: core components should be maximally token-dependent so themes have
full control over the visual output.

## Tokens in the registry

A registry item declares theme values through `cssVars`, and light / dark values
as tuples where a theme supports both modes. A `registry:theme` or `registry:base`
item defines the token set for the design system. See
[../registry.md](../registry.md) for the schema and
[../examples/registry-item.md](../examples/registry-item.md) for examples.

## Related

- [../api-conventions.md](../api-conventions.md) — the raw-value code smell.
- [../philosophy.md](../philosophy.md) — why tokens are the design contract.
