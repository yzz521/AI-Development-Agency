#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENCY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_DIR=""
WITH_GATE=0
for arg in "$@"; do
  case "$arg" in
    --with-gate|--gate) WITH_GATE=1;;
    -h|--help) echo "用法: $0 <项目目录> [--with-gate]"; exit 0;;
    -*) echo "错误：未知参数 $arg" >&2; exit 1;;
    *) if [ -n "$PROJECT_DIR" ]; then echo "错误：只能指定一个项目目录" >&2; exit 1; fi; PROJECT_DIR="$arg";;
  esac
done
[ -n "$PROJECT_DIR" ] || PROJECT_DIR="$(pwd)"
PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd)" || { echo "错误：项目目录不存在：$PROJECT_DIR" >&2; exit 1; }
[ "$PROJECT_DIR" = "$AGENCY_ROOT" ] && { echo "错误：不能初始化 AI-Development-Agency 自己"; exit 1; }

# 软链接建在 .ai/ 里，相对路径必须从 .ai/ 起算；项目可位于 workspace 任意深度（init-all.sh RECURSIVE=1）
# 纯参数展开实现，不依赖 here-string / 临时文件，兼容 bash 3.2
relpath() {
  local from="$1" to="$2" up=""
  while [ "$from" != "/" ]; do
    case "$to" in
      "$from"/*) printf '%s' "${up}${to#"$from"/}"; return 0;;
      "$from")   printf '%s' "${up%/}"; return 0;;
    esac
    from="${from%/*}"; [ -n "$from" ] || from="/"
    up="../$up"
  done
  printf '%s' "${up}${to#/}"
}

AI_DIR="$PROJECT_DIR/.ai"; LINK_PATH="$AI_DIR/agency"; REL="$(relpath "$AI_DIR" "$AGENCY_ROOT")"
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
# 不要在这里先复制模板再 install：detect_stack 会读 AGENTS.md 兜底，
# 而模板罗列了全部技术栈示例（连"检测技术栈：java,vue,..."这行都在），
# 先复制会让首次 init 的技术栈永远检测成全量，摘要失去裁剪意义。
# route.sh --install 自己会创建 AGENTS.md 并写入路由段，顺序交给它即可。
if [ -f "$PROJECT_DIR/AGENTS.md" ]; then
  echo "✓ 已存在 AGENTS.md，不覆盖正文（路由段由下一步刷新）"
fi
"$SCRIPT_DIR/route.sh" --install "$PROJECT_DIR"

# 门禁会 git config core.hooksPath 并写入 CI，属于"改变提交行为"的强制项，
# 因此不默认绑进 init——但给了 --with-gate 一键装全，避免"以为装完了其实没门禁"。
if [ "$WITH_GATE" = "1" ]; then
  echo
  "$SCRIPT_DIR/check.sh" --install "$PROJECT_DIR"
else
  echo "提示：门禁未安装。补装请跑 agency check --install（只卡增量），或用 agency init --with-gate 一步到位。"
fi
echo "完成：$PROJECT_DIR"
