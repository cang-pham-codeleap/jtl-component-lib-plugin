#!/usr/bin/env bash
# PreToolUse hook (matcher: Task): surface the model a subagent will run on.
#
# Claude Code renders the subagent header (cyan agent name + description) itself
# and exposes no config to append the model there. This hook instead emits a
# `systemMessage` on every Task dispatch, resolving the target agent's model from
# its `.claude/agents/<subagent_type>.md` frontmatter so you can confirm at a
# glance that e.g. deep-explore is actually on Haiku.
#
# Input (stdin): JSON with .tool_name ("Task") and .tool_input.subagent_type.
# Output (stdout): JSON `{ "systemMessage": "..." }`. Always exit 0 (never blocks).

set -euo pipefail

payload="$(cat)"

tool_name=$(printf '%s' "$payload" | jq -r '.tool_name // ""')
case "$tool_name" in Agent|Task) ;; *) exit 0 ;; esac

subagent=$(printf '%s' "$payload" | jq -r '.tool_input.subagent_type // ""')
[[ -n "$subagent" ]] || exit 0

# When installed as a plugin, Claude Code namespaces the subagent_type as
# "<plugin>:<agent>" (e.g. "comp-lib-process:deep-explore"). Strip the prefix so
# the frontmatter lookup below resolves the file name.
subagent_base="${subagent##*:}"

# Resolve the agent definition. Plugin install: $CLAUDE_PLUGIN_ROOT/agents/.
# Standalone/project install: $CLAUDE_PROJECT_DIR/.claude/agents/.
model=""
for agent_file in \
  "${CLAUDE_PLUGIN_ROOT:-}/agents/${subagent_base}.md" \
  "${CLAUDE_PROJECT_DIR:-.}/.claude/agents/${subagent_base}.md"; do
  [[ -n "$agent_file" && -f "$agent_file" ]] || continue
  # First `model:` line in the YAML frontmatter; strip quotes and trailing space.
  model=$(grep -m1 '^model:' "$agent_file" 2>/dev/null \
    | sed -E "s/^model:[[:space:]]*//; s/^[\"']//; s/[\"']$//; s/[[:space:]]+$//" || true)
  [[ -n "$model" ]] && break
done
[[ -n "$model" ]] || model="inherit (main session model)"

jq -nc --arg s "$subagent" --arg m "$model" \
  '{systemMessage: ("🤖 subagent " + $s + " → model: " + $m)}'

exit 0
