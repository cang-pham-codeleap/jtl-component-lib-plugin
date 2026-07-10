#!/usr/bin/env bash
#
# scaffold-agent-docs.sh
#
# Scaffolds the JTL agent documentation into a project:
#   - AGENTS.md         (repo-root entry point)
#   - CLAUDE.md         (thin file that references AGENTS.md)
#   - docs/agents/      (conventions folder)
#
# Idempotent: never overwrites existing content. It only creates what is missing
# and appends missing references. Safe to run repeatedly.
#
# Usage:
#   scaffold-agent-docs.sh [target_dir]
#
# target_dir defaults to the current working directory.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/templates"
TARGET_DIR="${1:-$PWD}"

if [[ ! -d "$TEMPLATES_DIR" ]]; then
  echo "error: templates directory not found at $TEMPLATES_DIR" >&2
  exit 1
fi

created=0
skipped=0
updated=0

# --- docs/agents/ ------------------------------------------------------------
mkdir -p "$TARGET_DIR/docs/agents"

while IFS= read -r -d '' src; do
  rel="${src#"$TEMPLATES_DIR"/docs/agents/}"
  dest="$TARGET_DIR/docs/agents/$rel"
  if [[ -e "$dest" ]]; then
    skipped=$((skipped + 1))
  else
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    echo "created docs/agents/$rel"
    created=$((created + 1))
  fi
done < <(find "$TEMPLATES_DIR/docs/agents" -type f -print0)

# --- AGENTS.md ---------------------------------------------------------------
agents_file="$TARGET_DIR/AGENTS.md"
if [[ ! -f "$agents_file" ]]; then
  cp "$TEMPLATES_DIR/AGENTS.md" "$agents_file"
  echo "created AGENTS.md"
  created=$((created + 1))
elif ! grep -q "docs/agents/" "$agents_file"; then
  cat >> "$agents_file" <<'EOF'

## JTL agent docs

This repository follows the JTL Component Library conventions. See
[docs/agents/](docs/agents/) for the full set:

- [docs/agents/architecture.md](docs/agents/architecture.md) — Atom / Component / Block / Recipe and API shape.
- [docs/agents/decision-matrix.md](docs/agents/decision-matrix.md) — which form a piece takes.
- [docs/agents/authoring/](docs/agents/authoring/) — component, block, recipe, tokens.
- [docs/agents/registry.md](docs/agents/registry.md) — registry.json, item types, publishing.
- [docs/agents/contributing.md](docs/agents/contributing.md) — spec-first workflow and PRs.
EOF
  echo "updated AGENTS.md (appended docs/agents reference)"
  updated=$((updated + 1))
else
  echo "skipped AGENTS.md (already references docs/agents)"
  skipped=$((skipped + 1))
fi

# --- CLAUDE.md ---------------------------------------------------------------
claude_file="$TARGET_DIR/CLAUDE.md"
if [[ ! -f "$claude_file" ]]; then
  cp "$TEMPLATES_DIR/CLAUDE.md" "$claude_file"
  echo "created CLAUDE.md"
  created=$((created + 1))
elif ! grep -q "AGENTS.md" "$claude_file"; then
  cat >> "$claude_file" <<'EOF'

This project's agent instructions live in [AGENTS.md](AGENTS.md).

@AGENTS.md
EOF
  echo "updated CLAUDE.md (appended AGENTS.md reference)"
  updated=$((updated + 1))
else
  echo "skipped CLAUDE.md (already references AGENTS.md)"
  skipped=$((skipped + 1))
fi

echo "agent docs scaffold: created=$created updated=$updated skipped=$skipped"
