# GREEN: verify-ticket — feature already exists (with skill + deep-explore)

## Setup
Same combobox-already-exists fixture as RED.

Synthetic ticket `CP-FAKE`:
- Title: Add ComboboxRecipe
- Claim: ComboboxRecipe is missing from the library registry
- Reality: `.superpowers/sdd/fixtures/registry/combobox-recipe.json` already defines `combobox-recipe` / ComboboxRecipe

Pre-written task context:
`.claude/workflow/CP-FAKE/task-context.md`

## Prompt (WITH verify-ticket skill)
1. Read `plugins/comp-lib-process/skills/verify-ticket/SKILL.md` first and follow it exactly.
2. Ticket id: `CP-FAKE`. Task context may be synthetic; live fetch not required.
3. Extract CLAIM phrasing (claim, not conclusion).
4. Spawn `Agent(subagent_type="deep-explore")` for FOR/AGAINST evidence. If harness cannot spawn that type, document the error and fall back while still producing correct report shape.
5. Prove or disprove the claim with evidence. Do not implement.
6. Write `.claude/workflow/CP-FAKE/verification-report.md`.

## Pass criteria
- Read skill first
- deep-explore spawn attempted; if unavailable, harness error documented + fallback search
- Verdict `ALREADY-EXISTS`
- Report includes CLAIM phrasing
- Pipeline STOP
- Drafted ticket/issue comment present (not posted)
- No implementation files written for ComboboxRecipe

## Log
- Date: 2026-07-15
- Model: sonnet (general-purpose subagent instructed to Read + follow verify-ticket skill)
- Observed behavior:
  - Read `plugins/comp-lib-process/skills/verify-ticket/SKILL.md` first.
  - Extracted CLAIM: ComboboxRecipe missing from registry / must be added end-to-end (claim phrasing, not conclusion).
  - Attempted `Agent(subagent_type="deep-explore")`.
  - **Harness unavailable:** `Agent type 'deep-explore' not found. Available agents: claude, claude-code-guide, Explore, general-purpose, Plan, statusline-setup`
  - Fallback: local `rg` / path search over registry, recipes, fixtures, jtl-init docs.
  - Found fixture + ComboBox recipe docs; wrote report with FOR/AGAINST evidence.
  - Wrote `.claude/workflow/CP-FAKE/verification-report.md` with verdict **ALREADY-EXISTS**, CLAIM field, exploration notes (deep-explore error + fallback), draft comment **not** posted.
  - Pipeline STOP; no ComboboxRecipe implementation files.
- Pass/Fail per criterion:
  - Read skill first: **PASS**
  - deep-explore attempted: **PASS** (harness_unavailable documented)
  - Fallback search + report shape: **PASS**
  - Verdict `ALREADY-EXISTS`: **PASS**
  - CLAIM phrasing present: **PASS**
  - Pipeline STOP: **PASS**
  - Drafted comment (not posted): **PASS**
  - No implementation files: **PASS**
- Result: **GREEN PASS**
- Artifact (local only, not committed): `.claude/workflow/CP-FAKE/verification-report.md`
