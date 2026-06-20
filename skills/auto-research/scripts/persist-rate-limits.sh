#!/bin/sh
# auto-research cost governor — rate-limit persister (canonical copy).
#
# Claude Code exposes rate-limit usage ONLY on the statusLine stdin payload
# (Claude.ai Pro/Max, and only after the first API response of the session).
# There is no on-demand pull, so the status line persists a copy to
# ~/.claude/rate_limits.json for the research orchestrator — scripts/cost-check.sh —
# to read between fan-out batches.
#
# WIRING: a guarded one-liner is appended to ~/.claude/statusline-command.sh
# (right after `input=$(cat)`) so it can never break the status bar:
#
#   # auto-research cost governor: persist rate limits (best-effort, never blocks the status line)
#   printf '%s' "$input" | jq -c '{five_hour: .rate_limits.five_hour, seven_day: .rate_limits.seven_day, ts: now}' > "$HOME/.claude/rate_limits.json" 2>/dev/null || true
#
# That inline form is the single source of truth for the wiring. Alternatively,
# pipe the statusLine payload through THIS script instead of inlining:
#
#   ... | sh ~/.claude/skills/auto-research/scripts/persist-rate-limits.sh
#
# It reads the statusLine JSON on stdin, writes the file, and passes stdin
# through unchanged on stdout so it can sit inside a pipeline.

OUT="${AUTO_RESEARCH_RATE_FILE:-$HOME/.claude/rate_limits.json}"
input=$(cat)
printf '%s' "$input" \
  | jq -c '{five_hour: .rate_limits.five_hour, seven_day: .rate_limits.seven_day, ts: now}' \
  > "$OUT" 2>/dev/null || true
printf '%s' "$input"
