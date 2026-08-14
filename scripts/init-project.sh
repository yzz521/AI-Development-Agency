#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENCY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_DIR="${1:-}"
if [ -z "$PROJECT_DIR" ]; then echo "用法: $0 <项目目录>"; exit 1; fi
PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd)" || { echo "错误：项目目录不存在：$1"; exit 1; }
[ "$PROJECT_DIR" = "$AGENCY_ROOT" ] && { echo "错误：不能初始化 AI-Development-Agency 自己"; exit 1; }
AI_DIR="$PROJECT_DIR/.ai"; LINK_PATH="$AI_DIR/agency"; REL="../$(basename "$AGENCY_ROOT")"; TEMPLATE="$AGENCY_ROOT/templates/project-AGENTS.md"
mkdir -p "$AI_DIR"
echo "==> 初始化项目：$PROJECT_DIR"
if [ -L "$LINK_PATH" ]; then
  CURRENT="$(readlink "$LINK_PATH")"
  if [ "$CURRENT" != "$REL" ]; then rm "$LINK_PATH"; ln -s "$REL" "$LINK_PATH"; echo "✓ 修复 .ai/agency -> $REL"; else echo "✓ .ai/agency 已正确指向当前 Agency"; fi
elif [ -e "$LINK_PATH" ]; then
  echo "错误：$LINK_PATH 已存在且不是软链接，请手工处理"; exit 1
else
  ln -s "$REL" "$LINK_PATH"; echo "✓ 创建 .ai/agency -> $REL"
fi
if [ ! -f "$PROJECT_DIR/AGENTS.md" ]; then
  cp "$TEMPLATE" "$PROJECT_DIR/AGENTS.md"
  echo "✓ 创建项目 AGENTS.md"
else
  echo "✓ 已存在 AGENTS.md，不覆盖"
fi
echo "完成：$PROJECT_DIR"
