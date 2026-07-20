# Copilot Cross-Harness Support Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver `comp-lib-process` through APM for GitHub Copilot while keeping Claude Code support and enforcing portable task-to-PR evidence in CI.

**Architecture:** APM treats `plugins/comp-lib-process` as the portable skill collection and compiles a repository-level Copilot instruction file. The skills use `.jtl/workflow` sanitized evidence, while Claude-specific hooks and agents remain adapters. A shell validator is the shared CI enforcement point.

**Tech Stack:** Agent Skills Markdown, APM YAML, Bash, GitHub Actions, Claude Code plugin manifests, GitHub Copilot instructions.

---

### Task 1: Add Portable Packaging

**Files:**

- Create: `apm.yml`
- Create: `plugins/comp-lib-process/skills/*/apm.yml`
- Create: `.apm/instructions/comp-lib-process.instructions.md`
- Create: `.github/instructions/comp-lib-process.instructions.md`
- Create: `AGENTS.md`
- Modify: `README.md`

- [ ] Add the APM collection manifest with the `copilot` target and CodeGraph MCP dependency.
- [ ] Add a portable instruction primitive that requires installed skills, Superpowers, `.jtl/workflow` evidence, and CI gates.
- [ ] Compile and commit the generated Copilot/AGENTS instruction outputs.
- [ ] Document APM and Copilot Superpowers installation.

### Task 2: Make Workflow Evidence Portable

**Files:**

- Modify: `plugins/comp-lib-process/skills/task-to-pr/SKILL.md`
- Modify: `plugins/comp-lib-process/skills/ticket-intake/SKILL.md`
- Modify: `plugins/comp-lib-process/skills/verify-ticket/SKILL.md`
- Modify: `plugins/comp-lib-process/skills/figma-fetching/SKILL.md`
- Modify: `plugins/comp-lib-process/skills/reflect/SKILL.md`
- Modify: `plugins/comp-lib-process/skills/create-pr/SKILL.md`
- Modify: `plugins/comp-lib-process/skills/teach-back-verification/SKILL.md`
- Modify: `plugins/comp-lib-process/skills/debt-review/SKILL.md`

- [ ] Replace active `.claude/workflow` paths with `.jtl/workflow`.
- [ ] Replace committed raw ticket/design payloads with sanitized summaries and explicit redaction rules.
- [ ] Preserve required Superpowers stages and add harness-specific unavailable-Superpowers remediation.
- [ ] Describe Claude agents as optional native accelerators rather than a portable requirement.

### Task 3: Enforce Artifacts in CI

**Files:**

- Create: `scripts/validate-cross-harness.sh`
- Create: `scripts/test-validate-cross-harness.sh`
- Create: `.github/workflows/validate-cross-harness.yml`

- [ ] Write fixture-driven tests that fail before the validator exists for missing approvals, raw ticket sections, secrets, and obsolete workflow paths.
- [ ] Implement the validator and run the tests green.
- [ ] Add CI for static validation, APM install/compile/audit where available, and generated-output drift.

### Task 4: Align Documentation and Evidence

**Files:**

- Modify: `README.md`
- Modify: `docs/task-to-pr-workflow.md`
- Modify: `docs/announcements/2026-07-16-task-to-pr-workflow.md`
- Modify: `plugins/comp-lib-process/skills/task-to-pr/task-to-pr-architecture.html`
- Create: `docs/superpowers/pressure-tests/copilot-cross-harness/README.md`
- Create: `docs/superpowers/pressure-tests/copilot-cross-harness/baseline.md`
- Create: `docs/superpowers/pressure-tests/copilot-cross-harness/with-skill.md`

- [ ] Document committed, sanitized evidence and branch-protection requirements.
- [ ] Update the diagram and public workflow text to use `.jtl/workflow`.
- [ ] Record baseline and passing pressure scenarios for Claude Code, Copilot local, and Copilot coding agent.

### Task 5: Verify the Release

**Files:**

- Modify: `.claude-plugin/marketplace.json`
- Modify: `plugins/comp-lib-process/.claude-plugin/plugin.json`

- [ ] Bump marketplace and Claude plugin versions together.
- [ ] Run shell tests, manifest parsing, `claude plugin validate`, APM validation/compile, and diff checks.
- [ ] Inspect the final diff for accidental raw ticket data and stale active workflow paths.
