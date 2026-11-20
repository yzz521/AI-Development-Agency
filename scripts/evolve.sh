#!/usr/bin/env bash
# agency evolve — 汇总近期真实反馈，生成 Curator 评审报告
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENCY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DAYS=30
OUTPUT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --days) DAYS="${2:-30}"; shift 2;;
    --output) OUTPUT="${2:-}"; shift 2;;
    -h|--help) echo "用法: agency evolve [--days 30] [--output <文件>]"; exit 0;;
    *) echo "未知参数: $1" >&2; exit 1;;
  esac
done
case "$DAYS" in ''|*[!0-9]*) echo "--days 必须是正整数" >&2; exit 1;; esac
[ "$DAYS" -gt 0 ] || { echo "--days 必须大于 0" >&2; exit 1; }
if [ -n "$OUTPUT" ]; then
  mkdir -p "$(dirname "$OUTPUT")"
  : > "$OUTPUT"
  exec > "$OUTPUT"
fi
if date -v-"$DAYS"d +%F >/dev/null 2>&1; then
  CUTOFF="$(date -v-"$DAYS"d +%F)"
else
  CUTOFF="$(date -d "-$DAYS days" +%F)"
fi
FB_DIR="$AGENCY_ROOT/evolution/feedback"
TOTAL=0; STALE=0; ACTIONABLE=0
echo "# Agency Evolution Review"
echo
echo "- Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "- Window: last $DAYS days (from $CUTOFF)"
echo
echo "## Feedback counts"
if [ -d "$FB_DIR" ]; then
  for f in "$FB_DIR"/*.md; do
    [ -f "$f" ] || continue
    d="$(basename "$f" .md)"
    [[ "$d" < "$CUTOFF" ]] && continue
    n="$(grep -c '^- kind:' "$f" || true)"
    [ "$n" -gt 0 ] || continue
    TOTAL=$((TOTAL+n))
    s="$(grep -c '^- kind: rule_stale$' "$f" || true)"
    STALE=$((STALE+s))
    a="$(grep -Ec '^- kind: (rule_gap|rule_stale|rule_violated|workflow_gap|context_gap)$' "$f" || true)"
    ACTIONABLE=$((ACTIONABLE+a))
    echo "- $d: $n feedback entries"
    grep -E '^- kind: (rule_applied|rule_violated|rule_gap|rule_stale|workflow_ok|workflow_gap|context_gap)$' "$f" | sort | uniq -c | sed 's/^/  - /'
  done
fi
echo
echo "## Recent evidence"
if [ -d "$FB_DIR" ]; then
  for f in "$FB_DIR"/*.md; do
    [ -f "$f" ] || continue
    d="$(basename "$f" .md)"
    [[ "$d" < "$CUTOFF" ]] && continue
    echo
    echo "### $d"
    grep -E '^## |^- (project|agent|task|kind|rule|detail):' "$f" || true
  done
fi
echo
echo "## Summary"
echo "- Total feedback: $TOTAL"
echo "- Actionable feedback: $ACTIONABLE"
echo "- rule_stale: $STALE"
if [ "$STALE" -gt 0 ] || [ "$ACTIONABLE" -ge 3 ]; then
  echo "- ACTION_REQUIRED=true"
  echo "- Trigger: stale rule feedback exists or actionable feedback reached threshold (3)."
  echo
  echo "## Curator actions"
  echo "1. Read the original feedback entries and verify their evidence."
  echo "2. Classify root causes; do not assume every issue needs a new rule."
  echo "3. Group semantically related reports only after reading context."
  echo "4. Create evidence-backed proposals for central Agency issues."
  echo "5. Prepare a PR; do not merge automatically."
else
  echo "- ACTION_REQUIRED=false"
  echo "- Trigger not reached; keep collecting evidence."
fi
