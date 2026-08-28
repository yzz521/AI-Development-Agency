#!/usr/bin/env bash
# ============================================================
# agency feedback — 记录规则使用反馈（自进化：采集层）
#
# 用法：
#   agency feedback --kind <类型> --detail "<描述>" [选项]
#
# 类型 (--kind)：
#   rule_applied   规则被正确应用（正面证据）
#   rule_violated  规则存在但未被遵守（规则不清晰？执行遗漏？）
#   rule_gap       遇到情况但没有规则覆盖（需要新规则）
#   rule_stale     规则已过时 / 与现状冲突
#   workflow_ok    workflow 有效
#   workflow_gap   workflow 缺失或不适配
#   context_gap    context 缺失或过时
#
# 选项：
#   --project <名>   项目名（默认当前目录名）
#   --agent <名>     使用的 Agent（如 java-developer）
#   --task <描述>    关联任务
#   --rule <路径>    关联规则文件（如 rules/java.md）
#   --proposal <id>  关联提案（若已创建）
#
# 反馈会追加写入 evolution/feedback/<日期>.md，
# 由 agency review / agency-curator 定期汇总处理。
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENCY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
KINDS="rule_applied rule_violated rule_gap rule_stale workflow_ok workflow_gap context_gap"

usage() { sed -n '3,28p' "$0" | sed 's/^# \{0,1\}//'; }

kind=""; detail=""; project=""; agent=""; task=""; rule=""; proposal=""
while [ $# -gt 0 ]; do
  case "$1" in
    --kind) kind="${2:-}"; shift 2;;
    --detail) detail="${2:-}"; shift 2;;
    --project) project="${2:-}"; shift 2;;
    --agent) agent="${2:-}"; shift 2;;
    --task) task="${2:-}"; shift 2;;
    --rule) rule="${2:-}"; shift 2;;
    --proposal) proposal="${2:-}"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "未知参数: $1" >&2; usage >&2; exit 1;;
  esac
done

[ -n "$kind" ]   || { echo "缺少 --kind（可用: $KINDS）" >&2; exit 1; }
[ -n "$detail" ] || { echo "缺少 --detail" >&2; exit 1; }
case " $KINDS " in *" $kind "*) ;; *) echo "非法 kind: $kind（可用: $KINDS）" >&2; exit 1;; esac
[ -z "$project" ] && project="$(basename "$(pwd)")"

if [ -n "$rule" ] && [ ! -f "$AGENCY_ROOT/$rule" ]; then
  echo "⚠ 规则文件不存在（仅提示）: $rule" >&2
fi

FB_DIR="$AGENCY_ROOT/evolution/feedback"
mkdir -p "$FB_DIR"
TODAY="$(date +%F)"; NOW="$(date +%H:%M)"
FILE="$FB_DIR/$TODAY.md"
[ -f "$FILE" ] || { echo "# 规则使用反馈 $TODAY" > "$FILE"; echo >> "$FILE"; }

{
  echo "## $NOW — ${project}${agent:+" / $agent"} — $kind"
  echo
  echo "- project: $project"
  [ -n "$agent" ]    && echo "- agent: $agent"
  [ -n "$task" ]     && echo "- task: $task"
  echo "- kind: $kind"
  [ -n "$rule" ]     && echo "- rule: $rule"
  [ -n "$proposal" ] && echo "- proposal: $proposal"
  echo "- detail: $detail"
  echo
} >> "$FILE"

echo "✓ 已记录反馈 → evolution/feedback/$TODAY.md"
echo "  后续可用 agency review 汇总，或 agency propose 直接升级为提案。"
