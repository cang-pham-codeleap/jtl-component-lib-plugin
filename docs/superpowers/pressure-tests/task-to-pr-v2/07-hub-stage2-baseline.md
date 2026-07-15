# RED: hub Stage 2 Speckit placeholder

## Prompt without superpowers Stage 2 recipe

Simple ticket already clarified. Ask agent to run Stage 2 (write the spec).

## Expected baseline

Agent cannot produce a real superpowers design: follows Speckit Bash stub, invents flags, or writes only `.claude/workflow/<id>/specs.md`.

## Setup

- Load **pre-change** hub Stage 2 text only:

  > ### Stage 2 — Spec → `speckit` CLI
  > - Consumes clarified context + verification corrections.
  > - Invoke via Bash: `speckit <fill in your actual command/flags here>` (local CLI, not Skill tool).
  > - Output: `.claude/workflow/<ticket-id>/specs.md`.
  >
  > 🛑 **Checkpoint 1 — Spec approval**
  > Print `specs.md`; wait for explicit approval. Hook writes `specs.approved`.
  >
  > ## Assumption to verify
  > `speckit` exact CLI flags remain environment-specific — fill before production use.

- Context (synthetic):
  - Ticket: CP-4216 — optional Button `size` prop sm|md|lg
  - Stage 1 pick: extend existing size tokens on Button
  - `task-context.md` has `## Clarified scope`
  - `verification-report.md`: CONFIRMED

## Prompt pressure (pre-change Stage 2)

"Stage 1 done; human picked option A. Run Stage 2 Spec now. Produce the approved-path artifact for writing-plans."

## Pass-as-baseline-failure (any one counts)

Without superpowers Stage 2 recipe, RED passes if the agent does **any** of:

1. Invokes or invents a `speckit` / Spec Kit Bash command (including "fill in flags" placeholder)
2. Writes only under a broken Speckit path / cannot land a real superpowers design at `.claude/workflow/<ticket-id>/specs.md`
3. Has no design self-review (placeholders/consistency/scope/ambiguity) before Checkpoint 1
4. Treats Stage 2 as full interactive brainstorming re-open by default

## Log

- Date: 2026-07-15
- Model: static + skill-diff analysis (pre-change Stage 2 text)
- Observed baseline (pre-change Stage 2 contract):
  - Hard-routes to Bash `speckit <fill in your actual command/flags here>`
  - Output path forced to `.claude/workflow/<ticket-id>/specs.md`
  - Explicit open assumption: flags environment-specific / unfilled
  - No superpowers design path, sections, or self-review checklist
  - No ban on Speckit/`specify`
- Contract checks:
  - Speckit dependency: **yes** → criterion 1
  - Superpowers design path required: **no** → criterion 2
  - Spec Self-Review required: **no** → criterion 3
- Result: **RED PASS** (Speckit placeholder cannot feed writing-plans superpowers pair)

## Note

Skill-text baseline. Live agent with pre-change hub either fails at missing `speckit` binary or invents non-portable CLI usage; neither reliably yields a superpowers-shaped design at `.claude/workflow/<ticket-id>/specs.md`.
