# Stage 4 group dispatch template

Fill the `{placeholders}` and dispatch as
`Agent(subagent_type="comp-lib-process:engine-specialist")` for `[logic]` tags,
or `Agent(subagent_type="comp-lib-process:ui-ux-stylist")` for `[ui]` tags.
This template bakes in the 3-phase contract and the return contract so the
subagent cannot stop after writing code — the orchestrator must use it verbatim,
not a hand-written shortened prompt.

Model: use the target agent's own frontmatter (primary + fallback array) —
see `references/model-routing.md`. Do not pass a different model unless
escalating per that file's Escalation section.

---

You own the `{tag}` task group for ticket `{ticket_id}` end to end, inside your
own context. The orchestrator does **not** run checks or commit for you —
phase 3 (verify + commit) is your responsibility, not a handoff.

**Read these first (your inputs — nothing else from the session):**
- Plan tasks for this group: `{plan_path}` (the `{tag}`-tagged tasks only)
- Ticket scope + clarified scope: `{task_context_path}`
- Spec (if FULL tier): `{specs_path}`

**You have Bash.** Use it for phase 3. Do not return partial work expecting the
orchestrator to finish it.

Work in 3 phases; **checks run once per group, never per task**:

1. **Tests** — write the failing tests for ALL tasks in the group, then **one**
   targeted run of only the new test files to confirm they fail.
2. **Implement** — write the code for ALL tasks. No check runs between tasks.
3. **Verify & commit** — run **tests + lint + typecheck once** (Bash) for the
   group; fix until green. **Do not run build** — the Stage 5 reviewer builds
   once. Then one commit per task — subject prefixed `{ticket_id}:`,
   conventional-commit format, no check re-runs between commits. **No
   AI-attribution trailer** (no `Co-Authored-By:`, no `Generated with`).
   Subject only, or subject + human-written body.

Git index is single-writer: commit only your own group's files, never another
agent's.

**Return contract (mandatory):**
- On success: commit SHA(s) + **check evidence** (exact commands run + output
  tail). Example:
  ```
  ## Stage 4 checks — [{tag}] group ({ticket_id})

  - Commits: <sha1> (Task 1), <sha2> (Task 2), ...
  - `npx tsc -b` → "No errors found" (or the fix you applied + re-run result)
  - `./node_modules/.bin/vitest run <targeted>` → N/N passed
  - `./node_modules/.bin/eslint <paths>` → clean
  ```
- On unfixable failure: return the failure — do not commit broken code. State
  which phase failed, the command, and the error.
- **Never return partial work without a SHA.** If phase 3 is not done, return
  `INCOMPLETE: phase 3 pending — <reason>` so the orchestrator can re-dispatch
  you to finish it. Do not silently leave code unverified/uncommitted.

If you hit a pre-existing failure unrelated to your diff (e.g. a snapshot drift
in a file you never touched), confirm it via `git stash` against the clean base
and note it in the evidence — do not fix unrelated files.
