#!/usr/bin/env bash
# ============================================================
# agency review — 生成本轮评审简报（自进化：评审层）
#
# 输出：
#   1. 待评审提案列表（evolution/proposals/）
#   2. 最近反馈（evolution/feedback/）
#   3. 反馈指标汇总（按 kind / 按规则）
#   4. 评审提醒（合并门槛，见 rules/evolution.md）
#
# 由 agency-curator（或人）按 workflows/evolution-review.md 执行。
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENCY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROP_DIR="$AGENCY_ROOT/evolution/proposals"
FB_DIR="$AGENCY_ROOT/evolution/feedback"
RECENT_DAYS="${1:-30}"

echo "═══════════════════ Agency 自进化评审简报 ═══════════════════"
echo "日期: $(date +%F)  |  统计窗口: 最近 ${RECENT_DAYS} 天"
echo

echo "── 1. 待评审提案（evolution/proposals/）──"
if [ -d "$PROP_DIR" ] && ls "$PROP_DIR"/*.md >/dev/null 2>&1; then
  for f in "$PROP_DIR"/*.md; do
    id="$(grep -m1 '^id:' "$f" | cut -d' ' -f2- || basename "$f" .md)"
    title="$(grep -m1 '^title:' "$f" | cut -d' ' -f2- || echo '?')"
    status="$(grep -m1 '^status:' "$f" | cut -d' ' -f2- || echo '?')"
    type="$(grep -m1 '^type:' "$f" | cut -d' ' -f2- || echo '?')"
    echo "  [$status] $id ($type) — $title"
  done
else
  echo "  （无待评审提案）"
fi
echo

echo "── 2. 最近反馈（evolution/feedback/，最近 ${RECENT_DAYS} 天）──"
if [ -d "$FB_DIR" ] && ls "$FB_DIR"/*.md >/dev/null 2>&1; then
  cutoff="$(date -v-${RECENT_DAYS}d +%F 2>/dev/null || date -d "-${RECENT_DAYS} days" +%F 2>/dev/null || echo "1970-01-01")"
  count=0
  for f in "$FB_DIR"/*.md; do
    d="$(basename "$f" .md)"
    [[ "$d" > "$cutoff" || "$d" == "$cutoff" ]] || continue
    echo "  $d:"
    grep -E '^## |^- (kind|project|rule|detail|task):' "$f" | head -12 | sed 's/^/    /'
    count=$((count+1))
  done
  [ "$count" -eq 0 ] && echo "  （窗口内无反馈）"
else
  echo "  （暂无反馈）"
fi
echo

echo "── 3. 指标汇总（最近 ${RECENT_DAYS} 天）──"
if [ -d "$FB_DIR" ] && ls "$FB_DIR"/*.md >/dev/null 2>&1; then
  grep -h '^- kind:' "$FB_DIR"/*.md | awk '{print $3}' | sort | uniq -c | sort -rn | sed 's/^/    /'
else
  echo "    （无数据）"
fi
echo

echo "── 4. 评审提醒（详细规则见 rules/evolution.md）──"
echo "    - 合并门槛：必须有证据、有影响面、向后兼容（破坏性需 MAJOR）"
echo "    - 合并后：改规则文件 → 更新 CHANGELOG → bump 版本 → 提案移入 archive/"
echo "    - 评审者：agency-curator；破坏性变更必须人工确认"
echo
echo "══════════════════════════════════════════════════════════"
