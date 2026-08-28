#!/usr/bin/env bash
# ============================================================
# agency task — 创建任务单（AI 执行完任务后填写，作为使用审计证据）
#
# 用法：
#   agency task [--title "标题"] [项目目录]
#
# 选项：
#   --title "标题"   预填任务标题
#   <项目目录>       默认当前目录
#
# 产物：<项目>/.ai/tasks/<日期>-<NN>.md（NN 为当日递增序号）
# 基于 templates/task-report.md。填完后用 agency audit 交叉核对。
# ============================================================
set -euo pipefail

# 解析脚本真实路径（支持符号链接调用）
SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
AGENCY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

title=""; project=""
while [ $# -gt 0 ]; do
  case "$1" in
    --title) title="${2:-}"; shift 2;;
    -h|--help) sed -n '3,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0;;
    *) project="$1"; shift;;
  esac
done
[ -z "$project" ] && project="$(pwd)"
project="$(cd "$project" 2>/dev/null && pwd)" || { echo "错误：项目目录不存在: $project" >&2; exit 1; }

TASK_DIR="$project/.ai/tasks"
mkdir -p "$TASK_DIR"
DATE="$(date +%Y%m%d)"
# 当日序号：统计当日已有任务单
n=1
while [ -e "$TASK_DIR/$DATE-$(printf '%02d' "$n").md" ]; do n=$((n+1)); done
ID="$DATE-$(printf '%02d' "$n")"
FILE="$TASK_DIR/$ID.md"

if [ -f "$AGENCY_ROOT/templates/task-report.md" ]; then
  cp "$AGENCY_ROOT/templates/task-report.md" "$FILE"
else
  echo "错误：缺少模板 templates/task-report.md" >&2; exit 1
fi
sed -i '' "s|<YYYYMMDD-NN>|$ID|; s|^标题：$|标题：$title|" "$FILE" 2>/dev/null \
  || sed -i "s|<YYYYMMDD-NN>|$ID|; s|^标题：$|标题：$title|" "$FILE"

echo "✓ 任务单已创建: $FILE"
echo "  任务完成后填写（读取/修改文件、验证、规则反馈），再用 agency audit 核验。"
