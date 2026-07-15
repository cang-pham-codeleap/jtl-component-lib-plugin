# GREEN: create-pr — diff-verified breaking changes (with skill)

## Fixture
Same as RED:
- Commit: `feat: remove public prop data from StepperLayout` (no `!`)
- Diff removes exported prop `data` from `packages/ui/src/components/StepperLayout/types.ts`
- Last tag: `v1.54.0`. Ticket: `CP-4216`

## Prompt (WITH updated create-pr skill)
1. Read `plugins/comp-lib-process/skills/create-pr/SKILL.md` first and follow Step 3 / 5 / 7 exactly.
2. Apply 3a (commit signal) + 3b (public-surface diff verification) + reconcile.
3. Dry-run: stop after Step 7 body generation — no `gh pr create`, no changelog edits, no push.

## Pass criteria
- Read skill first
- 3a tentative bump = minor (feat without `!`)
- 3b finds breaking public-surface change
- Final bump = **major**; next version 2.0.0
- User informed that `feat` understated the break
- BREAKING section / first bullet names real prop + file ref from verified diff
- Breaking sections not `None.`
- No real `gh pr create`

## Log
- Date: 2026-07-15
- Model: general-purpose subagent (skill Read first; default harness model)
- Observed behavior:
  - Read `plugins/comp-lib-process/skills/create-pr/SKILL.md` first.
  - 3a: `feat:` without `!` → tentative **minor**.
  - 3b: public-surface diff shows removed prop `data` on `StepperLayoutProps` → breaking present.
  - Reconcile: no `!` + breaking → escalate to **major**; notify understated commit.
  - Step 5 first bullet **BREAKING** from verified diff (prop + file path).
  - Step 7 breaking sections filled from diff (not `None.`); semver **major**.
  - Stopped after body generation (dry-run).
- Result keys:
  ```
  read_skill_first: yes
  tentative_bump_3a: minor
  diff_breaking_found: yes
  final_bump: major
  next_version: 2.0.0
  understated_commit_notified: yes
  understated_message: Commit `feat: remove public prop data from StepperLayout` (CP-4216) understated a breaking public-API change — should be feat! / major.
  breaking_what: Removed public prop `data` from `StepperLayoutProps` (`packages/ui/src/components/StepperLayout/types.ts`); `StepperLayout` no longer accepts `data`.
  breaking_who: Consumers that pass `data` to `StepperLayout`.
  breaking_migration: Stop passing `data` to `StepperLayout`; supply form data via the context provider instead.
  semver_bump: major
  summary_first_bullet: - **BREAKING:** `StepperLayout` no longer accepts `data` prop (`packages/ui/src/components/StepperLayout/types.ts`) — migrate by providing form data via context provider instead
  used_diff_not_only_bang: yes
  ```
- Pass/Fail per criterion:
  - Read skill first: **PASS**
  - 3a minor: **PASS**
  - 3b breaking found: **PASS**
  - Final major 2.0.0: **PASS**
  - Understated commit notified: **PASS**
  - BREAKING names prop + file: **PASS**
  - Dry-run (no gh pr create): **PASS**
- Result: **GREEN PASS**
