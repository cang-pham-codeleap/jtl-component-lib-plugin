# Philosophy

Why this library is built the way it is. These principles steer every decision in
the docs that follow.

## The problems we're solving

- **Ownership falls on the consumer.** Copy-paste component models shift
  maintenance to every app that copied the code. We accept that trade for
  control, and we manage it deliberately with tokens and a clear ownership model.
- **Styling systems create lock-in.** Coupling component logic to one styling
  approach forces consumers to adopt a CSS philosophy. shadcn atoms plus JTL
  tokens keep the styling contract open.
- **Customization is either too hard or too shallow.** We aim for deep
  customization with sensible constraints: theme tokens for visuals, composition
  for structure.
- **AI assistants struggle with component libraries.** The real cause is API
  complexity, implicit conventions, and poor recovery paths — not obscurity.
  Consistent conventions and clear recovery paths fix this for AI and humans alike.
- **Consistency breaks down at scale.** Without strong conventions, teams
  reimplement the same piece differently and the UI fragments.

## What we've learned

- **AI quality and human quality are the same thing.** Every fix that helps an AI
  assistant also helps a human. A 30-prop API is confusing for both.
- **Port the value, not the internal structure.** When migrating a legacy
  component, port what it is for — which props are actually used, which variants
  cover real cases — not how it was built internally.
- **Product building and system building need separate loops.** When a builder
  hits a gap, they unblock immediately (compose a Recipe, override a token, own
  the copy). The system team consolidates those signals and evolves the library.

## How we work

- **Guidance over enforcement.** Components provide capability, not design
  guardrails. Design opinions live in docs and examples, not runtime prop gating.
- **Test assumptions, don't debate them.** When two API shapes seem equally
  valid, build both and evaluate which one an agent reaches for naturally, rather
  than arguing.
- **Hold principles loosely.** These conventions are the best answers we have so
  far. When a new situation shows a principle is wrong, update it.
- **Dogfood relentlessly.** The registry, the docs, and the recipes are used the
  same way a consumer uses them. Friction we feel is friction we fix.

## Pillars for this library

1. **Registry-first distribution.** UI ships as open code through the registry, so
   agents can read each item, its props, and how it composes.
2. **Tokens as the design contract.** Visuals live in themeable tokens; structure
   lives in components. Designers own tokens, developers own behavior.
3. **Composition as the default.** New work is composed and owned; a property API
   is earned once a design stabilizes.
4. **CLI and MCP as the companion.** The shadcn CLI and MCP are the operational
   interface — the most reliable documentation driver we have.
5. **AI-assisted stewardship.** Convention audits, doc review, and research run
   with AI assistance. See [maintenance.md](maintenance.md).

## Related

- [architecture.md](architecture.md) — the layering and API shape.
- [api-conventions.md](api-conventions.md) — the conventions that emerged from these principles.
- [contributing.md](contributing.md) — how these principles apply to a change.
