#!/usr/bin/env bash
# ============================================================
# agency propose — 创建规范改进提案（自进化：提案层）
#
# 用法：
#   agency propose --type <类型> --title "<标题>" [选项]
#
# 类型 (--type)：
#   rule-add       新增规则
#   rule-change    修改规则
#   rule-remove    废弃/删除规则
#   workflow-add   新增 workflow
#   workflow-change 修改 workflow
#   context-add    新增/更新 context
#   agent-add      新增 Agent
#   other          其他
#
# 选项：
#   --evidence "<证据>"   来自哪个项目/任务的实际观察（必填，评审门槛）
#   --author "<署名>"     提案人（默认 git config user.name）
#   --impact "<影响>"     影响哪些 agent/rule（可多次）
#
# 产物：evolution/proposals/<日期>-<slug>.md（front matter + 正文模板）
# 之后由 agency-curator 按 workflows/evolution-review.md 评审合并。
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENCY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TYPES="rule-add rule-change rule-remove workflow-add workflow-change context-add agent-add other"

usage() { sed -n '3,27p' "$0" | sed 's/^# \{0,1\}//'; }

type=""; title=""; evidence=""; author=""; impact=""
while [ $# -gt 0 ]; do
  case "$1" in
    --type) type="${2:-}"; shift 2;;
    --title) title="${2:-}"; shift 2;;
    --evidence) evidence="${2:-}"; shift 2;;
    --author) author="${2:-}"; shift 2;;
    --impact) impact="${2:-}"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "未知参数: $1" >&2; usage >&2; exit 1;;
  esac
done

[ -n "$type" ]  || { echo "缺少 --type（可用: $TYPES）" >&2; exit 1; }
case " $TYPES " in *" $type "*) ;; *) echo "非法 type: $type（可用: $TYPES）" >&2; exit 1;; esac
[ -n "$title" ] || { echo "缺少 --title" >&2; exit 1; }
[ -z "$evidence" ] && { echo "缺少 --evidence（提案必须带真实项目/任务证据）" >&2; exit 1; }
[ -z "$author" ] && author="$(git -C "$AGENCY_ROOT" config user.name 2>/dev/null || echo "unknown")"

DATE="$(date +%Y%m%d)"
slug="$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9一-龥' '-' | sed 's/-\+/-/g; s/^-//; s/-$//')"
[ -n "$slug" ] || slug="untitled"
PROP_DIR="$AGENCY_ROOT/evolution/proposals"
mkdir -p "$PROP_DIR"
FILE="$PROP_DIR/$DATE-$slug.md"
[ -e "$FILE" ] && { echo "错误：提案已存在: $FILE" >&2; exit 1; }

{
  echo "---"
  echo "id: $DATE-$slug"
  echo "title: $title"
  echo "type: $type"
  echo "author: $author"
  echo "status: draft"
  echo "created: $(date +%F)"
  echo "evidence:"
  echo "  - $evidence"
  echo "impact:"
  [ -n "$impact" ] && echo "  - $impact" || echo "  - (待补充：影响哪些 agent / rule / workflow)"
  echo "---"
  echo
  echo "# 提案：$title"
  echo
  echo "## 背景与证据"
  echo
  echo "$evidence"
  echo
  echo "## 现状问题"
  echo
  echo "（描述当前规则/规范缺失或不适配的具体情况）"
  echo
  echo "## 建议变更"
  echo
  echo "（给出拟新增/修改/删除的规则原文或要点）"
  echo
  echo "## 影响面"
  echo
  echo "- 影响的 Agent："
  echo "- 影响的 Rule / Workflow："
  echo "- 兼容性：向后兼容 / 破坏性（需 MAJOR 版本）"
  echo
  echo "## 评审记录"
  echo
  echo "| 日期 | 评审人 | 结论 | 备注 |"
  echo "| --- | --- | --- | --- |"
  echo
} > "$FILE"

echo "✓ 提案已创建: evolution/proposals/$DATE-$slug.md"
echo "  状态 draft。完成正文后，用 agency review 进入评审流程。"
