#!/usr/bin/env bash
# ============================================================
# agency require — 创建需求单（给"人"提需求用）
#
# 用法：
#   agency require [--title "标题"] [项目目录]
#
# 选项：
#   --title "标题"   预填需求标题（生成文件名与标题行）
#   <项目目录>       默认当前目录
#
# 产物：<项目>/.ai/requirements/<日期>-<slug>.md
# 基于 templates/requirement.md，生成后直接编辑填写。
# 填完交给 AI，AI 按 AGENTS.md 标准执行方式处理。
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
    -h|--help) sed -n '3,15p' "$0" | sed 's/^# \{0,1\}//'; exit 0;;
    *) project="$1"; shift;;
  esac
done
[ -z "$project" ] && project="$(pwd)"
project="$(cd "$project" 2>/dev/null && pwd)" || { echo "错误：项目目录不存在: $project" >&2; exit 1; }

REQ_DIR="$project/.ai/requirements"
mkdir -p "$REQ_DIR"
DATE="$(date +%Y%m%d)"
if [ -n "$title" ]; then
  slug="$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9一-龥' '-' | sed 's/-\+/-/g; s/^-//; s/-$//')"
  [ -n "$slug" ] || slug="requirement"
else
  slug="requirement"
fi
FILE="$REQ_DIR/$DATE-$slug.md"

if [ -f "$AGENCY_ROOT/templates/requirement.md" ]; then
  cp "$AGENCY_ROOT/templates/requirement.md" "$FILE"
else
  echo "错误：缺少模板 templates/requirement.md" >&2; exit 1
fi
[ -n "$title" ] && sed -i '' "s/^- 标题：/- 标题：$title/" "$FILE" 2>/dev/null \
  || sed -i "s/^- 标题：/- 标题：$title/" "$FILE"

echo "✓ 需求单已创建: $FILE"
echo "  编辑填写后，交给 AI 执行（AI 按 AGENTS.md 标准执行方式处理）。"
