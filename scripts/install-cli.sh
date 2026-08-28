#!/usr/bin/env bash
# ============================================================
# install-cli.sh — 把 agency 命令安装到 PATH
#
# 用法：
#   ./scripts/install-cli.sh            # 安装到 ~/bin（存在时）或 ~/.local/bin
#   AGENCY_BIN=~/tools ./scripts/install-cli.sh   # 自定义目录
# ============================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENCY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TARGET_DIR="${AGENCY_BIN:-}"
if [ -z "$TARGET_DIR" ]; then
  if [ -d "$HOME/bin" ]; then TARGET_DIR="$HOME/bin"; else TARGET_DIR="$HOME/.local/bin"; fi
fi
mkdir -p "$TARGET_DIR"
ln -sf "$AGENCY_ROOT/scripts/agency.sh" "$TARGET_DIR/agency"
echo "✓ 已安装: $TARGET_DIR/agency -> $AGENCY_ROOT/scripts/agency.sh"
if [[ ":$PATH:" != *":$TARGET_DIR:"* ]]; then
  echo "⚠ PATH 尚未包含 $TARGET_DIR"
  echo "  临时使用:  export PATH=\"$TARGET_DIR:\$PATH\""
  echo "  永久使用:  将上面这行加入 ~/.zshrc 或 ~/.bashrc"
fi
echo "验证: agency version"
