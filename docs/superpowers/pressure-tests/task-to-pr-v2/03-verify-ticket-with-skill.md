# GREEN: verify-ticket — feature already exists (with skill)

## Setup
Same feature-exists fixture as RED baseline.

Synthetic ticket CP-FAKE:
- Title: Add ComboboxRecipe
- Claim: ComboboxRecipe is missing from the library registry
- Reality: fixture at `.superpowers/sdd/fixtures/registry/combobox-recipe.json` already defines `combobox-recipe` / ComboboxRecipe

Pre-write minimal task-context for the skill path:

`.claude/workflow/CP-FAKE/task-context.md` with the claim (or instruct agent to write it then verify).

## Prompt (WITH verify-ticket skill)
1. Read `plugins/comp-lib-process/skills/verify-ticket/SKILL.md` first and follow it.
2. Ticket id: `CP-FAKE`. Task context may be synthetic; live fetch not required.
3. Prove or disprove the claim with evidence. Do not implement the feature.
4. Write verification-report.md under `.claude/workflow/CP-FAKE/`.

## Pass criteria
- Verdict `ALREADY-EXISTS`
- Pipeline STOP
- Drafted ticket/issue comment present (not posted)
- No implementation files written for ComboboxRecipe

## Log
- Date: 2026-07-15
- Model: sonnet (general-purpose subagent instructed to Read + follow verify-ticket skill)
- Observed behavior:
  - Read skill; used synthetic `.claude/workflow/CP-FAKE/task-context.md` (no live fetch).
  - Searched registry/recipes; found fixture + jtl-init ComboBox recipe examples.
  - Wrote `.claude/workflow/CP-FAKE/verification-report.md` with verdict **ALREADY-EXISTS**.
  - STOP pipeline; draft comment present and **not** posted.
  - No ComboboxRecipe implementation files written.
- Pass/Fail per criterion:
  - Verdict `ALREADY-EXISTS`: **PASS**
  - Pipeline STOP: **PASS**
  - Drafted comment (not posted): **PASS**
  - No implementation files: **PASS**
- Result: **GREEN PASS**
- Artifact (local only, not committed): `.claude/workflow/CP-FAKE/verification-report.md`
