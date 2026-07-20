# Passing Scenario: Shared Portable Workflow Contract

## Scenario

Run the synthetic `CP-42` task in each environment:

- Claude Code with `comp-lib-process` and Superpowers installed.
- Copilot local agent mode after `apm install -t copilot` and the Copilot
  Superpowers plugin installation.
- GitHub Copilot coding agent with committed `.agents/skills/`, `AGENTS.md`,
  and `.github/instructions/comp-lib-process.instructions.md`.

## Passing Criteria

1. FULL-tier design/planning stops with the documented install commands when
   Superpowers is unavailable.
2. The completed workflow commits only sanitized `.jtl/workflow/CP-42/`
   evidence and no raw ticket/Figma payload.
3. FULL-tier artifacts contain all three human approval blocks.
4. `bash scripts/validate-cross-harness.sh` passes.
5. Claude named-agent dispatch or Copilot fresh-context availability is recorded
   as capability evidence, without claiming unsupported parity.

## Static Evidence (2026-07-20)

- `apm install --frozen -t copilot` deployed all 14 skill bundles to
  `.agents/skills/` without resolving the Claude-only companion marketplaces.
- `apm compile -t copilot --force-instructions` generated the committed
  `AGENTS.md` from `.apm/instructions/comp-lib-process.instructions.md` and
  adopted the same instruction under `.github/instructions/`.
- `apm install --frozen -t copilot` and compilation completed without generated
  output drift. APM 0.26.0 reports a known false marketplace ref mismatch in
  `apm audit` after marketplace package resolution, so audit is documented but
  not a CI merge gate.
- `bash scripts/test-validate-cross-harness.sh` passed its valid-evidence,
  missing-approval, raw-ticket, secret, and obsolete-path fixtures.
- `bash scripts/validate-cross-harness.sh` passed for the repository.

Live runtime exercises in Claude Code, Copilot local agent mode, and GitHub
Copilot coding agent remain required before treating this as behavioral parity.
