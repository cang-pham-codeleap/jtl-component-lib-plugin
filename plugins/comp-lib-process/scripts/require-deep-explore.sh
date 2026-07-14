#!/usr/bin/env bash
# PreToolUse hook: force parent agents to dispatch `deep-explore` before
# raw exploration. Only `deep-explore` itself bypasses the check.
#
# Input (stdin): JSON payload from Claude Code with fields:
#   - tool_name
#   - tool_input  (includes file_path for Read, pattern for Grep/Glob)
#   - transcript_path
#   - agent (subagent type; empty/"main" for root agent)
#   - user_message (latest user prompt)
#
# Exit 0 = allow. Exit 2 = block with stderr message shown to agent.

set -euo pipefail

payload="$(cat)"

tool_name=$(printf '%s' "$payload" | jq -r '.tool_name // ""')
# Claude Code's PreToolUse payload carries the running agent's type as top-level
# `.agent_type` (e.g. "general-purpose"); it is absent/empty for the MAIN agent.
# Keep `.agent`/`.subagent_type` as fallbacks for other harness versions.
agent_type=$(printf '%s' "$payload" | jq -r '.agent_type // .agent // .subagent_type // ""')
transcript_path=$(printf '%s' "$payload" | jq -r '.transcript_path // ""')
user_message=$(printf '%s' "$payload" | jq -r '.user_message // .prompt // ""')
target_path=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // .tool_input.path // ""')

# Extract Bash command early (needed for Bash gating below).
bash_cmd=$(printf '%s' "$payload" | jq -r '.tool_input.command // ""')

# Gate only raw exploration tools that dump uncompressed content into context.
# NOT gated: ctx_*, code-review-graph, RTK — they already produce compressed output.
# The point is to force raw file reads through deep-explore (Haiku) so it can
# summarize before returning to parent (Opus/Sonnet).
case "$tool_name" in
  Read|Grep|Glob) ;; # Always fall through to enforcement checks below
  Bash)
    # Allow RTK commands — already compresses output (60-90% savings).
    if printf '%s' "$bash_cmd" | grep -qE '^rtk[[:space:]]'; then
      exit 0
    fi
    # Gate raw Bash exploration targeting source files.
    if printf '%s' "$bash_cmd" | grep -qE '(^|[;&|()][[:space:]]*)(cat|head|tail|less|wc|find|ls|bat|rg|fd|grep)([[:space:]]|$)'; then
      if printf '%s' "$bash_cmd" | grep -qE "(src/|\.ts|\.tsx|\.js|\.jsx|\.prisma|\.md)"; then
        : # fall through to enforcement below
      else
        exit 0
      fi
    else
      exit 0
    fi
    ;;
  *) exit 0 ;;
esac

# Only the MAIN agent is gated. ANY subagent bypasses: a subagent already runs in
# its own isolated context that is discarded once it returns a summary, so its raw
# reads never bloat the main thread. Forcing an execution subagent (general-purpose,
# engine-specialist, …) to nest ANOTHER deep-explore just triples cost
# (main → worker → deep-explore) for no benefit. deep-explore is itself a subagent,
# so it is covered here too. Main agent reports empty / "main" / "root" / "default".
#
# Detection uses TWO independent signals; either one identifies a subagent. This is
# resilient to Claude Code payload-schema drift — if a version stops populating
# `.agent_type`, the child-session env vars still catch every subagent.
#   1. Env: child sessions export CLAUDE_CODE_CHILD_SESSION=1 (and a distinct
#      CLAUDE_CODE_SESSION_ID); the MAIN agent does not set CLAUDE_CODE_CHILD_SESSION.
#   2. Payload: `.agent_type` is non-empty for a subagent, absent for MAIN.
if [[ -n "${CLAUDE_CODE_CHILD_SESSION:-}" || -n "${CLAUDE_CODE_SUBAGENT:-}" ]]; then
  exit 0  # running inside a subagent → bypass the gate, read directly
fi
case "$agent_type" in
  "" | main | root | default) ;; # main agent → keep enforcing below
  *) exit 0 ;;                    # any subagent → bypass the gate
esac

# Read gating model (tuned for long sessions): the enemy of a multi-hour session
# is context bloat. Every file kept in the main window is re-sent as a cache-read
# on EVERY later turn and pushes the session toward compaction (which invalidates
# the whole prompt cache). So raw bytes that are NOT needed for an edit should be
# absorbed by a deep-explore subagent (one-time cost, never re-sent). But spinning
# a subagent for a tiny file costs more than just keeping it — so small reads pass
# directly. The hook only routes to deep-explore once a read is genuinely large.
if [[ "$tool_name" == "Read" ]]; then
  # Tunables — when a read is big enough that its recurring cache-read cost over
  # the session outweighs deep-explore's one-time setup cost:
  max_recent_reads=2      # files already read in the recent window
  large_file_lines=100    # a single file this big is itself "large context"

  # Detect edit intent — used ONLY to let a large EDIT-prep read through.
  # Editing a big file needs its bytes in context anyway, so blocking it gives
  # no benefit and only forces a subagent "read exact content" fetch that floods
  # the main thread. Large UNDERSTANDING reads (no edit intent) still route out.
  edit_intent=0
  if [[ -n "$user_message" ]] && printf '%s' "$user_message" | grep -qiE "(edit|update|fix|add|modify|replace|refactor|implement|change|create|write|remove|delete|build|migrate|move|rename|convert|sửa|chỉnh|cập nhật|thêm|xoá|xóa|đổi|tạo|viết|chuyển|di chuyển)"; then
    edit_intent=1
  fi

  # (a) How many reads have happened recently (≈ the current task window)?
  recent_reads=0
  if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
    recent_reads=$(tail -n 800 "$transcript_path" 2>/dev/null | grep -coE '"(Read|read_file)"' || true)
  fi

  # (b) Is the target file itself very large?
  big_file=0
  if [[ -n "$target_path" && -f "$target_path" ]]; then
    lines=$(wc -l < "$target_path" 2>/dev/null | tr -d '[:space:]' || true)
    if [[ "$lines" =~ ^[0-9]+$ && "$lines" -gt "$large_file_lines" ]]; then
      big_file=1
    fi
  fi

  # 0. Allow a small read, OR a large read when the intent is to edit it.
  #    Covers edit-prep reads and light exploration, kept cache-local without
  #    subagent overhead. Large UNDERSTANDING reads (no edit intent) are blocked
  #    once the task is large — that is when deep-explore's one-time summary beats
  #    paying the bytes as cache-read every later turn.
  if [[ "$recent_reads" -lt "$max_recent_reads" && ( "$big_file" -eq 0 || "$edit_intent" -eq 1 ) ]]; then
    exit 0
  fi

  # 1. Backward check: transcript already shows an Edit on this file (re-read after partial edit).
  if [[ -n "$target_path" && -f "$target_path" && -n "$transcript_path" && -f "$transcript_path" ]]; then
    escaped_path=$(printf '%s' "$target_path" | sed 's/[.[\*^$()+?{|\\]/\\&/g')
    if tail -n 300 "$transcript_path" 2>/dev/null | grep -qE "(Edit|apply_patch|replace_string_in_file|multi_replace_string_in_file|create_file).*$escaped_path"; then
      exit 0
    fi
  fi

  # 2. Explicit path: user references the exact target file path.
  if [[ -n "$target_path" && -n "$user_message" ]]; then
    if printf '%s' "$user_message" | grep -Fq "$target_path"; then
      exit 0
    fi
  fi
fi

# NOTE: Blanket "deep-explore was dispatched" bypass REMOVED.
# Only deep-explore itself may explore. Other agents use the exemptions above.

# Loop breaker: if THIS exact file was already blocked once in the recent
# transcript, allow it now. This guarantees forward progress for a Read that is
# genuinely the prerequisite of an Edit — a deep-explore subagent's Read does
# NOT satisfy the main session's "Edit requires a prior Read" rule, so without
# this escape "edit → read → block → deep-explore → edit → read → …" could loop
# forever. Each file is therefore blocked at most once: the cap adds one nudge
# of friction, the retry always succeeds.
if [[ "$tool_name" == "Read" && -n "$target_path" && -n "$transcript_path" && -f "$transcript_path" ]]; then
  if tail -n 600 "$transcript_path" 2>/dev/null | grep -Fq "DEEP_EXPLORE_BLOCK: $target_path"; then
    exit 0
  fi
fi

# Emit a machine-readable marker (consumed by the loop breaker above on retry)
# before the human-readable guidance.
if [[ -n "$target_path" ]]; then
  printf 'DEEP_EXPLORE_BLOCK: %s\n' "$target_path" >&2
fi

cat >&2 <<'MSG'
Blocked: this is large exploration — dispatch `deep-explore` (see CLAUDE.md Exploration Protocol).

Reads cross into deep-explore only past the large-exploration threshold (many
files already read, or a single large file). Routing large reads to a subagent
keeps the main context lean: those bytes are absorbed once instead of re-sent as
a cache-read every later turn, which delays compaction and preserves cache hits.

Use:
  Agent(subagent_type="deep-explore", description="...", prompt="...")

Still allowed WITHOUT deep-explore (cheap, cache-local):
  - Small reads under the threshold (edit-prep or light exploration).
  - Read on a file already being edited in the current transcript.
  - User message contains the exact target file path.
  - Retry of the SAME file after one block (loop breaker — proceed to Read+Edit).
Grep/Glob/Bash-exploration: use ctx_*, code-review-graph, or RTK instead.
MSG
exit 2
