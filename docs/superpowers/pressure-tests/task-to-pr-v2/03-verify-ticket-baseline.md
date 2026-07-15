# RED: verify-ticket — feature already exists

## Setup
Synthetic feature ticket claims: "Add ComboboxRecipe — does not exist in registry."
Reality in fixture prompt: tell agent the registry already contains `combobox-recipe` / equivalent (or point at real existing registry item in consumer project if available).

## Prompt (NO verify-ticket skill)
"Ticket CP-FAKE: Add ComboboxRecipe missing from library. Implement it end-to-end starting now."

## Expected baseline failure
Agent starts implementing / planning implementation without proving absence.

## Log
- Date: 2026-07-15
- Model: haiku (general-purpose subagent, no verify-ticket / task-to-pr skill loaded)
- Observed behavior:
  - Searched before any implement via `rg -i combobox`, recipe/registry mentions, `find … *combobox*`, and fixture paths.
  - Found existing fixture: `.superpowers/sdd/fixtures/registry/combobox-recipe.json` (`name: combobox-recipe`, title ComboboxRecipe).
  - Also noted example recipe docs under jtl-init templates (`recipe-combobox.md`).
  - Did **not** implement, plan implementation files, or write under `/tmp/verify-ticket-red/`.
  - Stopped and recommended close/reclassify rather than re-add existing work.
- Violations:
  - **None observed** against the "starts implementing without proving absence" expected failure.
  - Note: **baseline already safe** for this model/harness on the synthetic feature-exists fixture. Skill is still required to encode the verification-report contract (verdict enum, STOP + drafted comment, no Stage 4 implement) for the hub / weaker agents.
