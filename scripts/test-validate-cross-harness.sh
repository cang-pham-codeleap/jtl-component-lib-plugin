#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
validator="$repo_root/scripts/validate-cross-harness.sh"
fixture_root="$(mktemp -d)"
trap 'rm -rf "$fixture_root"' EXIT

create_valid_fixture() {
  local directory="$1"
  mkdir -p "$directory/.jtl/workflow/CP-42"
  cat > "$directory/.jtl/workflow/CP-42/task-context.md" <<'EOF'
# Task context - CP-42

- **Sources:** https://github.com/example/repo/issues/42
- **Source of truth:** github
- **ticket-id:** CP-42
- **Title:** Add a portable workflow

## Acceptance criteria

- The workflow runs in both supported harnesses.

## Clarified scope

- tier: full
EOF
  cat > "$directory/.jtl/workflow/CP-42/verification-report.md" <<'EOF'
# Verification report - CP-42

- **Verdict:** CONFIRMED
EOF
  cat > "$directory/.jtl/workflow/CP-42/specs.md" <<'EOF'
# Portable workflow design

## Approval

- Approved-by: Test User
- Date: 2026-07-20
- Mode: interactive
EOF
  cat > "$directory/.jtl/workflow/CP-42/plan.md" <<'EOF'
# Portable workflow plan

## Approval

- Approved-by: Test User
- Date: 2026-07-20
- Mode: interactive
EOF
  cat > "$directory/.jtl/workflow/CP-42/review-verdict.md" <<'EOF'
# Review verdict - CP-42

- **Verdict:** CLEAN

## Approval

- Approved-by: Test User
- Date: 2026-07-20
- Mode: interactive
EOF
}

expect_success() {
  local name="$1"
  shift
  if "$@"; then
    printf 'PASS: %s\n' "$name"
  else
    printf 'FAIL: %s\n' "$name" >&2
    exit 1
  fi
}

expect_failure() {
  local name="$1"
  shift
  if "$@"; then
    printf 'FAIL: %s unexpectedly passed\n' "$name" >&2
    exit 1
  else
    printf 'PASS: %s\n' "$name"
  fi
}

valid_fixture="$fixture_root/valid"
create_valid_fixture "$valid_fixture"
expect_success "accepts complete sanitized workflow evidence" bash "$validator" "$valid_fixture"

missing_approval="$fixture_root/missing-approval"
create_valid_fixture "$missing_approval"
rm "$missing_approval/.jtl/workflow/CP-42/plan.md"
cat > "$missing_approval/.jtl/workflow/CP-42/plan.md" <<'EOF'
# Portable workflow plan
EOF
expect_failure "rejects missing full-tier approval" bash "$validator" "$missing_approval"

raw_ticket="$fixture_root/raw-ticket"
create_valid_fixture "$raw_ticket"
printf '\n## Ticket body (untrusted)\n\nRaw ticket data\n' >> "$raw_ticket/.jtl/workflow/CP-42/task-context.md"
expect_failure "rejects raw ticket sections" bash "$validator" "$raw_ticket"

secret="$fixture_root/secret"
create_valid_fixture "$secret"
printf '\napi_key = "AKIAIOSFODNN7EXAMPLE"\n' >> "$secret/.jtl/workflow/CP-42/task-context.md"
expect_failure "rejects apparent secrets" bash "$validator" "$secret"

obsolete_path="$fixture_root/obsolete-path"
create_valid_fixture "$obsolete_path"
printf '\nSee .claude/workflow/CP-42/task-context.md\n' >> "$obsolete_path/.jtl/workflow/CP-42/task-context.md"
expect_failure "rejects obsolete Claude workflow paths" bash "$validator" "$obsolete_path"

otel_fixture="$fixture_root/otel.jsonl"
otel_report="$fixture_root/otel-report.json"
cat > "$otel_fixture" <<'EOF'
{"resourceSpans":[{"scopeSpans":[{"spans":[{"name":"invoke_agent","startTimeUnixNano":"1000000000","endTimeUnixNano":"3000000000","attributes":[{"key":"gen_ai.usage.input_tokens","value":{"intValue":"100"}},{"key":"gen_ai.usage.output_tokens","value":{"intValue":"20"}},{"key":"gen_ai.usage.cache_read.input_tokens","value":{"intValue":"70"}},{"key":"gen_ai.agent.name","value":{"stringValue":"copilot"}}]},{"name":"execute_tool","startTimeUnixNano":"1500000000","endTimeUnixNano":"1750000000","attributes":[{"key":"gen_ai.tool.name","value":{"stringValue":"readFile"}}]}]}]}]}
EOF
bash "$repo_root/scripts/summarize-otel-jsonl.sh" "$otel_fixture" "$otel_report"
[[ "$(jq -r '.agent_invocations' "$otel_report")" == "1" ]] || exit 1
[[ "$(jq -r '.tool_calls' "$otel_report")" == "1" ]] || exit 1
[[ "$(jq -r '.input_tokens' "$otel_report")" == "100" ]] || exit 1
[[ "$(jq -r '.output_tokens' "$otel_report")" == "20" ]] || exit 1
[[ "$(jq -r '.cache_read_tokens' "$otel_report")" == "70" ]] || exit 1
[[ "$(jq -r '.duration_ms' "$otel_report")" == "2000" ]] || exit 1
[[ "$(jq -r '.models.copilot' "$otel_report")" == "1" ]] || exit 1
expect_success "summarizes sanitized OpenTelemetry JSONL" test -s "$otel_report"

telemetry_baseline="$fixture_root/telemetry-baseline.json"
telemetry_evaluation="$fixture_root/telemetry-evaluation.json"
cat > "$telemetry_baseline" <<'EOF'
{
  "schema_version": 1,
  "scenario": "synthetic-otel-parser",
  "expected": {
    "span_count": 2,
    "agent_invocations": 1,
    "tool_calls": 1,
    "error_count": 0,
    "duration_ms": 2000,
    "input_tokens": 100,
    "output_tokens": 20,
    "reasoning_tokens": 0,
    "cache_read_tokens": 70,
    "models": { "copilot": 1 }
  }
}
EOF
bash "$repo_root/scripts/check-telemetry-baseline.sh" "$otel_report" "$telemetry_baseline" "$telemetry_evaluation"
[[ "$(jq -r '.verdict' "$telemetry_evaluation")" == "PASS" ]] || exit 1
[[ "$(jq -r '.differences | length' "$telemetry_evaluation")" == "0" ]] || exit 1
expect_success "accepts matching sanitized telemetry baseline" test -s "$telemetry_evaluation"

telemetry_regression_baseline="$fixture_root/telemetry-regression-baseline.json"
telemetry_regression_evaluation="$fixture_root/telemetry-regression-evaluation.json"
jq '.expected.tool_calls = 2' "$telemetry_baseline" > "$telemetry_regression_baseline"
expect_failure "rejects telemetry baseline regressions" \
  bash "$repo_root/scripts/check-telemetry-baseline.sh" \
  "$otel_report" "$telemetry_regression_baseline" "$telemetry_regression_evaluation"
[[ "$(jq -r '.verdict' "$telemetry_regression_evaluation")" == "FAIL" ]] || exit 1
[[ "$(jq -r '.differences[0].field' "$telemetry_regression_evaluation")" == "tool_calls" ]] || exit 1

task_audit="$fixture_root/task-audit.json"
TASK_AUDIT_OTEL_JSONL="$otel_fixture" \
TASK_AUDIT_OUTPUT_PATH="$task_audit" \
  bash "$repo_root/scripts/audit-task.sh"
[[ "$(jq -r '.schema_version' "$task_audit")" == "1" ]] || exit 1
[[ "$(jq -r '.telemetry.status' "$task_audit")" == "available" ]] || exit 1
[[ "$(jq -r '.telemetry.aggregate.input_tokens' "$task_audit")" == "100" ]] || exit 1
[[ "$(jq -r '.baseline.status' "$task_audit")" == "not-configured" ]] || exit 1
expect_success "creates a local task audit from available telemetry" test -s "$task_audit"

task_audit_without_telemetry="$fixture_root/task-audit-without-telemetry.json"
TASK_AUDIT_DIRECTORY="$fixture_root/no-telemetry" \
TASK_AUDIT_OUTPUT_PATH="$task_audit_without_telemetry" \
  bash "$repo_root/scripts/audit-task.sh"
[[ "$(jq -r '.telemetry.status' "$task_audit_without_telemetry")" == "unavailable" ]] || exit 1
[[ "$(jq -r '.telemetry.reason' "$task_audit_without_telemetry")" == *"No OTel JSONL trace found"* ]] || exit 1
expect_success "creates a task audit when telemetry is unavailable" test -s "$task_audit_without_telemetry"
