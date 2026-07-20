# Baseline: Claude-Only Workflow Contract

## Scenario

Ask a Copilot session to implement synthetic issue `CP-42` with the pre-change
Claude-only task-to-PR instructions.

## Expected Baseline Failure

- The session cannot discover the workflow as a portable skill.
- It writes or requests `.claude/workflow/` evidence, which is ignored and not
  CI-verifiable.
- It cannot receive a harness-specific Superpowers remediation command.

## Result Criteria

This baseline fails portability when no committed, sanitized
`.jtl/workflow/CP-42/` contract exists.
