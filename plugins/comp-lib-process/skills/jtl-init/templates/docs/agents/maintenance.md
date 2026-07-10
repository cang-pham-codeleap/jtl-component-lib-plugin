# Maintenance

Conventions for ongoing stewardship of the library. These are written conventions,
not an automation. They describe the mindset for keeping the library healthy as it
evolves, whether a human or an agent does the work.

## Why this exists

Components regress silently. A hardcoded color sneaks in. A new variant forgets a
token. A refactor drops a `displayName`. None of these break tests, but they break
the design and theming contracts. The point of maintenance is to catch drift
before it compounds.

## Principles

1. **Small, safe changes only.** Fixes are scoped to what is broken: type errors,
   lint failures, test regressions, missing exports, token drift. No feature work,
   no refactors of passing code.
2. **Don't block people.** When maintainers arrive, everything should be green and
   every open item should be actionable.
3. **Leave a trail.** Every action is logged so a maintainer can see exactly what
   changed and why.
4. **Stay in your lane.** Health work does not add capability. Capability goes
   through the spec workflow in [contributing.md](contributing.md).
5. **Never merge or approve without a human.** Review, comment, and fix — humans
   make the final call.

## What to check

Continuously enforce the Layer 1 audit from [hardening.md](hardening.md): token
usage, component reuse, prop and type naming, structure, input consistency, and
accessibility contracts. When a finding exceeds health scope (a new prop, a naming
dispute), route it to the spec workflow instead of fixing it in place.

## No AI-slop

Everything authored — PR bodies, commit messages, issue comments, review comments,
and doc prose — reads like a careful engineer wrote it:

- No buzzword filler (seamless, leverage, utilize, robust, delve, elevate, unlock,
  empower, cutting-edge, powerful, effortless).
- No significance padding ("it's worth noting", "plays a crucial role", "in today's
  world").
- No hollow intensifiers (very, truly, simply, easily).
- No "not only ... but also" or "isn't just X, it's Y" rhetoric.
- Straight quotes `'` `"` and `...`, not curly characters. Commas and semicolons,
  not em dashes.

## The bar

Before posting any comment or opening any fix, ask: **would a senior engineer on
this project bother saying this?** If not, stay silent. What works is acting as a
contributor (diagnosing deeply, implementing fixes) — not narrating what CI
already shows.

## Related

- [hardening.md](hardening.md) — the checklist this enforces.
- [contributing.md](contributing.md) — where capability work goes.
