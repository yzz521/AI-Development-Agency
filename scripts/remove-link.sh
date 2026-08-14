#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR="${1:-}"; [ -n "$PROJECT_DIR" ] || { echo "用法: $0 <项目目录>"; exit 1; }
PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd)" || exit 1
LINK="$PROJECT_DIR/.ai/agency"
if [ -L "$LINK" ]; then rm "$LINK"; echo "✓ 已删除 $LINK"; else echo "未找到 $LINK"; fi
