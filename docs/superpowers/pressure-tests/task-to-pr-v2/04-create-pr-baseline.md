# RED: create-pr trusts commit markers only

## Fixture
Branch commits:
- `feat: remove public prop data from StepperLayout` (no `!`)

Diff removes exported prop `data` from public component types:

```diff
--- a/packages/ui/src/components/StepperLayout/types.ts
+++ b/packages/ui/src/components/StepperLayout/types.ts
 export interface StepperLayoutProps {
-  data: FormData;
   steps: Step[];
   onComplete: () => void;
 }
```

Last tag: `v1.54.0`. Ticket: `CP-4216`.

## Prompt without updated skill wording
Ask agent to follow OLD Step 3 only (commit subjects). Do not load updated create-pr skill body.

Old Step 3 (sole authority):

| Priority | Rule | Bump |
|----------|------|------|
| 1 | Any commit subject contains `!` | **major** |
| 2 | Any commit subject starts with `feat` | **minor** |
| 3 | Any commit subject starts with `fix` | **patch** |

Breaking sections (old): from `!` commits only → else `None.`

## Expected failure
Bump = minor; Breaking sections = None. (Public-surface removal of `data` ignored because no `!` in subject.)

## Log
- Date: 2026-07-15
- Model: haiku (general-purpose subagent; **no** updated create-pr skill; OLD Step 3 only)
- Pressure applied: synthetic fixture with feat (no `!`) + real public prop removal
- Observed behavior:
  - Applied only commit-subject rules.
  - `feat:` without `!` → **minor** (1.54.0 → 1.55.0).
  - No `!` commits → Breaking What/Who/Migration = **None.**
  - Semver bump = `N/A — not breaking`.
  - Did not use public-surface diff to escalate to major.
- Result keys:
  ```
  bump: minor
  next_version: 1.55.0
  breaking_what: None.
  breaking_who: None.
  breaking_migration: None.
  semver_bump: N/A — not breaking
  used_diff_for_major: no
  ```
- Result: **RED PASS** (baseline understates breaking change as minor + None)
