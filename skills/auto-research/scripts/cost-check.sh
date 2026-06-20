#!/bin/sh
# auto-research cost governor — reader.
#
# Reads ~/.claude/rate_limits.json (kept fresh by the status line; see
# persist-rate-limits.sh) and prints ONE verdict line the orchestrator branches on:
#
#   verdict=<ok|warn|soft|hard|unknown> max=<n|-> five_hour=<n|-> seven_day=<n|-> age=<secs|-> reason=<...>
#
# Severity is also mirrored in the exit code for scripting (e.g. the watchdog):
#   0 = ok/warn   10 = soft   20 = hard   30 = unknown
#
# Policy: take max(5h, 7d). DEGRADE OPEN — absent / empty / stale / no-numbers /
# parse-error all return `unknown` so the caller PROCEEDS (never throttle on a
# missing metric). Thresholds: warn>=70, soft>=85, hard>=95. Freshness TTL 15m.
#
# Overridable via env: AUTO_RESEARCH_RATE_FILE, AUTO_RESEARCH_RATE_TTL.

RATE_FILE="${AUTO_RESEARCH_RATE_FILE:-$HOME/.claude/rate_limits.json}"
TTL="${AUTO_RESEARCH_RATE_TTL:-900}"   # seconds; older => stale => unknown
WARN=70; SOFT=85; HARD=95

if [ ! -s "$RATE_FILE" ]; then
  echo "verdict=unknown max=- five_hour=- seven_day=- age=- reason=absent"
  exit 30
fi

out=$(jq -r \
  --argjson ttl "$TTL" --argjson warn "$WARN" --argjson soft "$SOFT" --argjson hard "$HARD" '
  (now - (.ts // 0))                  as $age
  | (.five_hour.used_percentage // null) as $fh
  | (.seven_day.used_percentage // null) as $sd
  | ([$fh, $sd] | map(select(. != null))) as $vals
  | if ($vals | length) == 0 then
      "verdict=unknown max=- five_hour=\($fh // "-") seven_day=\($sd // "-") age=\($age|floor) reason=no-numbers"
    elif ($age > $ttl) then
      "verdict=unknown max=\($vals|max|floor) five_hour=\($fh // "-") seven_day=\($sd // "-") age=\($age|floor) reason=stale"
    else
      ($vals|max) as $m
      | (if $m >= $hard then "hard" elif $m >= $soft then "soft" elif $m >= $warn then "warn" else "ok" end) as $v
      | "verdict=\($v) max=\($m|floor) five_hour=\($fh // "-") seven_day=\($sd // "-") age=\($age|floor) reason=fresh"
    end
' "$RATE_FILE" 2>/dev/null)

if [ -z "$out" ]; then
  echo "verdict=unknown max=- five_hour=- seven_day=- age=- reason=parse-error"
  exit 30
fi

echo "$out"
case "$out" in
  *verdict=hard*)    exit 20 ;;
  *verdict=soft*)    exit 10 ;;
  *verdict=unknown*) exit 30 ;;
  *)                 exit 0  ;;
esac
