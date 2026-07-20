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
