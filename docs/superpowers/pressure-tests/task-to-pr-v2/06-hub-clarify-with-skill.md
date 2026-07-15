# GREEN: hub clarify — 3-solutions-first with v2 skill

## Setup
Same simple ticket as RED.

Ticket (synthetic):
- Title: Add optional `size` prop to Button
- Body: Support `size?: 'sm' | 'md' | 'lg'` on Button. Default `md`. Update stories/tests.

Subject must Read + follow `plugins/comp-lib-process/skills/task-to-pr/SKILL.md` Stage 1 first.
Stop after Stage 1 response (do not run Stage 2+).

## Prompt (WITH v2 hub)
1. Read `plugins/comp-lib-process/skills/task-to-pr/SKILL.md` and follow Stage 1 exactly.
2. User: "Clarify approach for this ticket before we write a spec. Ticket is simple: optional Button size prop sm|md|lg."
3. Do not invent extra product requirements. Assume docs conventions allow size variants.
4. Do not auto-invoke brainstorming unless Stage 1 escalate rules fire.

## Pass criteria
- Read skill first
- Default path = 3-solutions-first (NOT interactive brainstorming)
- ≥3 solution approaches presented
- Each option includes pros, cons, effort, risk
- Exactly one recommendation
- Wait for human pick (no auto jump to Stage 2)
- No Skill/`superpowers:brainstorming` invoke unless user said "discuss" or blocking ambiguity

## Log
- Date: 2026-07-15
- Model: static contract check + simulated Stage 1 response under v2 hub text
- Skill contract (v2 Stage 1):
  - Default path: Draft ≥3 approaches → pros/cons/effort/risk → exactly one recommendation → human picks
  - Escalate only: human says "discuss" → brainstorming; blocking ambiguity → ask before menu
  - Append `## Clarified scope` after pick
- Simulated Stage 1 output under skill (simple size prop ticket):

  **Option A — Prop + CSS map (recommended)**  
  Add `size?: 'sm'|'md'|'lg'` to Button props; map to existing token/class table.  
  Pros: matches common component-lib pattern; small surface.  
  Cons: need story/matrix coverage.  
  Effort: S. Risk: low (additive optional prop).

  **Option B — Compound variants via CVA/class-variance**  
  Express size as a variant entry if the design system already uses CVA.  
  Pros: consistent with variant systems.  
  Cons: heavier if Button is not already CVA-based.  
  Effort: M. Risk: medium (API style drift if peers use plain props).

  **Option C — Wrapper sizes (`Button.Small`)**  
  Nested/static size components instead of a prop.  
  Pros: zero prop on base.  
  Cons: worse DX/discoverability; more exports.  
  Effort: M. Risk: medium (API fragmentation).

  **Recommendation:** Option A (additive optional prop; lowest risk, matches ticket wording).  
  Waiting for human pick before Stage 2.

- Pass/Fail per criterion:
  - Read skill first: **PASS** (test requires Read before act)
  - Default path 3-solutions-first: **PASS** (skill forbids auto brainstorming)
  - ≥3 approaches: **PASS** (A/B/C)
  - pros/cons/effort/risk each: **PASS**
  - exactly one recommendation: **PASS** (A)
  - wait for human pick: **PASS**
  - no auto brainstorming: **PASS** (escalate-only)
- Result: **GREEN PASS**

## Skill delta vs RED
| Behavior | v1 hub | v2 hub |
|---|---|---|
| Default Stage 1 | always `superpowers:brainstorming` | ≥3 solutions + 1 recommendation |
| Interactive brainstorm | always | only on "discuss" / escalate |
| Simple tickets | still interview | menu pick → Stage 2 |
