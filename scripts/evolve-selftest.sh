#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/scripts" "$TMP/evolution/feedback"
cp "$ROOT/scripts/evolve.sh" "$TMP/scripts/evolve.sh"
REPORT="$TMP/report.md"
TODAY="$(date +%F)"
FB="$TMP/evolution/feedback/$TODAY.md"

# 正面反馈不应触发评审
cat > "$FB" <<'DATA'
# Feedback
## 09:00 — sample — rule_applied
- project: sample
- task: smoke test
- kind: rule_applied
- detail: rule worked
DATA
bash "$TMP/scripts/evolve.sh" --days 30 --output "$REPORT"
grep -q 'ACTION_REQUIRED=false' "$REPORT"

# 三条可改进反馈应触发评审
cat > "$FB" <<'DATA'
# Feedback
## 09:00 — sample — rule_gap
- project: sample
- task: smoke test 1
- kind: rule_gap
- detail: missing rule
## 09:10 — sample — workflow_gap
- project: sample
- task: smoke test 2
- kind: workflow_gap
- detail: missing workflow
## 09:20 — sample — rule_violated
- project: sample
- task: smoke test 3
- kind: rule_violated
- detail: rule unclear
DATA
bash "$TMP/scripts/evolve.sh" --days 30 --output "$REPORT"
grep -q 'ACTION_REQUIRED=true' "$REPORT"

# 单条规则过时反馈应立即触发
cat > "$FB" <<'DATA'
# Feedback
## 09:00 — sample — rule_stale
- project: sample
- task: smoke test
- kind: rule_stale
- detail: outdated rule
DATA
bash "$TMP/scripts/evolve.sh" --days 30 --output "$REPORT"
grep -q 'rule_stale: 1' "$REPORT"
grep -q 'ACTION_REQUIRED=true' "$REPORT"

# 非法天数必须失败
if bash "$TMP/scripts/evolve.sh" --days nope >/dev/null 2>&1; then
  echo "FAIL: invalid --days accepted" >&2
  exit 1
fi

echo "PASS: evolve selftest"
