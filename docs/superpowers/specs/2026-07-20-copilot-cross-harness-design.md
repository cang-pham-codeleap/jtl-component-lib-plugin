# Copilot Cross-Harness Support Design

## Goal

Make `comp-lib-process` usable from GitHub Copilot local agent mode and GitHub
Copilot coding agent while preserving the existing Claude Code marketplace
installation and its native enhancements.

## Scope

- Keep Claude Code's `.claude-plugin/` marketplace and companion-plugin
  dependencies.
- Add APM as the portable distribution path for this plugin's skills and
  CodeGraph MCP configuration.
- Require Superpowers on both Claude Code and Copilot.
- Move task-to-PR evidence to committed, sanitized
  `.jtl/workflow/<ticket-id>/` directories.
- Make repository CI validate portable workflow evidence and APM/Copilot output.

Out of scope:

- Replacing Claude's named subagents, hooks, or companion marketplace plugins in
  Copilot.
- Auto-configuring repository MCP servers for GitHub Copilot coding agent;
  administrators configure those in repository Settings because APM cannot set
  GitHub-hosted agent MCP configuration.
- Retrofitting historical specs, plans, pressure-test records, or process logs.

## Distribution Architecture

### Claude Code

Claude Code remains a native consumer of:

- `.claude-plugin/marketplace.json`
- `plugins/comp-lib-process/.claude-plugin/plugin.json`
- plugin-local agents, commands, hooks, and `.mcp.json`

The existing `superpowers@claude-plugins-official` dependency remains required.
Claude hooks and role agents are an acceleration and stronger local guardrail;
portable workflow correctness must not depend on them.

### GitHub Copilot

The repository-root `apm.yml` targets `copilot`, catalogs required marketplace
sources, declares CodeGraph as a stdio MCP dependency, and lists each existing skill bundle under
`plugins/comp-lib-process/skills/`. Each bundle has an `apm.yml` for APM
integrity metadata. APM deploys skills to `.agents/skills/`, compatible with
both local Copilot and GitHub Copilot coding agent.

Consumer repositories commit the generated Copilot assets when they need
GitHub Copilot coding agent to read them from the checkout:

- `.agents/skills/<skill>/` for each installed portable skill
- `AGENTS.md`
- `.github/instructions/comp-lib-process.instructions.md`

This publisher repository ignores its local `.agents/` deployment because APM
regenerates it in each consumer. Its CI validates that installation succeeds;
consumer CI checks generated-asset drift after committing the generated output.

The generated instruction assets direct Copilot to load the installed skills,
use `.jtl/workflow/`, honor the portable workflow policy, and treat
Superpowers as mandatory for planning stages.

Developers install with:

```bash
apm install cang-pham-codeleap/jtl-component-lib-plugin/plugins/comp-lib-process -t copilot
apm compile -t copilot
```

The documentation states that a consumer repository commits its `apm.yml`,
`apm.lock.yaml`, generated Copilot assets, and workflow evidence with the task
PR. CI registers the cataloged marketplaces, uses `apm install --frozen -t
copilot` and `apm compile -t copilot`, then rejects generated-output drift.
The external packages use their canonical Git references because APM 0.26.0
does not preserve marketplace identities in its lockfile.

### Superpowers Prerequisite

The task-to-PR workflow requires Superpowers. It must stop before Stage 2 or
Stage 3 when the harness cannot invoke `superpowers:brainstorming` or
`superpowers:writing-plans`.

For Copilot, the exact remediation is:

```bash
copilot plugin marketplace add obra/superpowers-marketplace
copilot plugin install superpowers@superpowers-marketplace
```

For Claude Code, the existing native plugin dependency supplies Superpowers.
If it is unavailable, the skill provides the existing marketplace install
guidance rather than attempting a substitute design or planning process.

## Portable Workflow Contract

### Artifact Root and Privacy

All current workflow references change from `.claude/workflow/` to
`.jtl/workflow/`. The root is committed, not ignored.

Ticket intake must write a sanitized summary, not raw source data. The committed
`task-context.md` may include ticket identifiers, URLs, title, labels, source
of truth, acceptance criteria, clarification outcomes, artifact pointers, and
check evidence. It must not include raw GitHub/Jira/Figma bodies, comments,
author information, secrets, or personal data. The raw-data and untrusted-body
sections are removed from the committed template.

Required artifact shape:

```text
.jtl/workflow/<ticket-id>/
  task-context.md
  verification-report.md
  design-context.md          # only when Figma URLs exist
  specs.md                   # FULL tier only
  plan.md                    # FULL tier only
  state.json                 # only when review loop state is needed
  review-verdict.md
  teach-back-report.md       # FULL tier only
```

`specs.md`, `plan.md`, and `review-verdict.md` each receive an `## Approval`
block only after explicit human approval. SIMPLE work records its approved
change list in `task-context.md`. No `*.approved` marker files are allowed.

### Harness-Neutral Behavior

Skills describe required outcomes first: gather evidence, implement, review
independently when the harness supports it, record check evidence, and stop at
human approvals.

Claude Code uses named role agents and hooks where available. Copilot uses its
available agent/session workflow. If a fresh context cannot be created, the
agent records that limitation in `review-verdict.md`, completes the documented
self-review, and relies on required CI and human approval as the final gate.

The skills must not falsely claim that Copilot has Claude `Agent`, `PreToolUse`,
or `Stop` capabilities. Claude-specific syntax stays in the Claude adapter
assets (agents, hooks, commands, and scripts), while portable skill text names
the required role and behavior.

`task-to-pr` and `resolve-pr-comment` retain their Superpowers invocations.
`create-pr` reads `.jtl/workflow/*/task-context.md` and prefers the matching
`.jtl/workflow/*/specs.md`, eliminating its obsolete
`docs/superpowers/specs/` lookup.

## CI and Branch Protection

Add a PR workflow that runs a repository validation script. The script checks:

- JSON and YAML manifests parse.
- Marketplace and plugin versions remain aligned.
- Every published `SKILL.md` has matching portable frontmatter and an APM
  collection entry.
- APM Copilot installation/compile/audit are reproducible from the committed
  lockfile and produce no drift.
- A task PR containing `.jtl/workflow/<ticket-id>/` has required files for its
  tier, valid approval blocks, and no obsolete `.claude/workflow/` artifact.
- Committed workflow evidence does not contain blocked raw-payload headings or
  obvious secret patterns.

The workflow does not infer whether every PR is a task-to-PR workflow. It
validates an artifact directory when one is present; the human/agent workflow
requires it for task-to-PR work. Repository administrators must make this CI
check required on `main` with GitHub branch protection. GitHub protection, not
agent instruction, is the hard protection against merging without the check.

## Documentation and Validation

The README gains separate Claude Code and Copilot installation sections,
including Superpowers installation, APM commands, generated-file ownership,
and GitHub Copilot coding-agent MCP configuration boundaries. It removes stale
references to a SessionStart dependency installer that is not shipped.

Automated tests cover artifact validation, redaction failures, APM manifest
coverage, and stale `.claude/workflow` references in active product files.
Pressure tests run the same fixture ticket in Claude Code, Copilot local agent
mode, and Copilot coding agent. The passing result must show the same sanitized
artifact contract and successful CI validation; harness-specific subagent
behavior is documented as capability evidence rather than treated as parity.

## Error Handling

- Missing Superpowers: stop before design/planning and provide harness-specific
  installation commands.
- Missing or inaccessible ticket/Figma integration: record the exact failure;
  do not invent source data or design content.
- Copilot fresh-context limitation: record it in the review verdict; do not
  assert the Claude isolation gate ran.
- CI validation failure: block merge until artifacts/manifests are corrected or
  the task evidence is intentionally removed because the PR is not a workflow
  task.

## Acceptance Criteria

1. `comp-lib-process` remains installable through Claude Code's marketplace.
2. APM installs its skill collection for the `copilot` target and emits
   committed Copilot instruction assets.
3. Copilot users receive exact Superpowers setup commands and task-to-PR stops
   if Superpowers is unavailable.
4. Active workflow skills use committed `.jtl/workflow/` artifacts only.
5. Task evidence is sanitized and CI rejects prohibited raw-payload/secret
   content.
6. CI validates APM output, manifests, and workflow evidence, and documentation
   explains the required GitHub branch-protection configuration.
7. Claude Code and both Copilot modes pass the shared task-to-PR pressure
   scenario with the portable artifact contract.
