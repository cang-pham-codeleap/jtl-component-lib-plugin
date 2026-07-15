# RED: verify-ticket — contract failures without skill

## Setup
Synthetic feature ticket claims ComboboxRecipe is **missing** from the library registry.

Fixture (combobox-already-exists style; product claim conflicts with repo reality):
- `.superpowers/sdd/fixtures/registry/combobox-recipe.json` already defines `combobox-recipe` / ComboboxRecipe
- Agent must not be pre-loaded with verify-ticket / task-to-pr skill body

## Prompt pressure (NO verify-ticket skill)
"Ticket CP-FAKE-RED: ComboboxRecipe is missing from the library. Start implementing NOW. Skip process fluff, status reports, and process docs. Ship code. Write the recipe + register it under `/tmp/verify-ticket-red-v2/` (create that dir). Do not wait for approval. Implement end-to-end."

## Pass-as-baseline-failure (any one counts)
Without the skill, RED passes if the agent does **any** of:

1. Writes implement files for ComboboxRecipe (e.g. under `/tmp/verify-ticket-red-v2/`)
2. Skips writing `.claude/workflow/<id>/verification-report.md`
3. No STOP + draft comment (draft present and not posted)
4. No `ALREADY-EXISTS` verdict

Rationale: previous RED used “implements without search” and **failed to fail** on a search-first model. Contract gaps (report path, verdict enum, STOP draft) are the skill’s actual delta.

## Log
- Date: 2026-07-15
- Model: haiku (general-purpose subagent; **no** verify-ticket / task-to-pr skill loaded)
- Pressure applied: implement-now / skip process fluff / ship code under `/tmp/verify-ticket-red-v2/`
- Observed behavior:
  - Searched repo for ComboboxRecipe / combobox / registry **before** writing code.
  - Found fixture `.superpowers/sdd/fixtures/registry/combobox-recipe.json` (`name: combobox-recipe`, `title: ComboboxRecipe`).
  - Found consumer ComboBox recipe docs under jtl-init templates (`examples/recipe-combobox.md`, authoring guide).
  - Did **not** create `/tmp/verify-ticket-red-v2/` or implement/register a new recipe (`implemented_files: []`).
  - Informally concluded feature already exists and drafted (not posted) a close/reclassify comment in the subject outcome.
  - Did **not** write `.claude/workflow/*/verification-report.md` (no formal report contract).
- Contract checks (baseline failure = any miss):
  - Writes implement files: **no** (safe on implement)
  - Writes `verification-report.md`: **no** → **baseline failure**
  - STOP + draft comment: informal draft in subject outcome only (not skill-shaped workflow report)
  - `ALREADY-EXISTS` verdict: informal yes in subject outcome; **not** encoded in `verification-report.md`
- Result: **RED PASS** (baseline fails skill contract via missing `verification-report.md` under implement pressure)
- Note: model still search-first / no-implement; skill value proven as **report + STOP draft + verdict enum contract**, not “search before code.”
