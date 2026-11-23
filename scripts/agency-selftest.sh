#!/usr/bin/env bash
# 防止 agency CLI 再次出现帮助文本误执行、参数丢失和 Shell 语法回归。
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENCY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CLI="$SCRIPT_DIR/agency.sh"

PASS=0
FAIL=0
ok() { echo "✓ $1"; PASS=$((PASS+1)); }
fail() { echo "✗ $1" >&2; FAIL=$((FAIL+1)); }

echo "== Agency CLI regression self-test =="

# 1. 帮助区域只能包含注释，避免示例命令被 Bash 当作顶层命令执行。
if awk '
  /^# 用法：$/ { in_usage=1; next }
  in_usage && /^# ===/ { found_end=1; exit }
  in_usage && /^[[:space:]]*$/ { next }
  in_usage && !/^[[:space:]]*#/ { print "未注释的帮助文本: " NR ": " $0; bad=1 }
  END { if (!found_end) { print "未找到帮助区域结束标记"; bad=1 } exit bad }
' "$CLI"; then
  ok "CLI 帮助区域全部为注释"
else
  fail "CLI 帮助区域存在可执行文本或结构异常"
fi

# 2. agency.sh 顶层不得出现裸 agency 命令，防止脚本启动时递归调用自身。
if grep -nE '^[[:space:]]*agency([[:space:]]|$)' "$CLI"; then
  fail "agency.sh 存在未注释的裸 agency 命令"
else
  ok "agency.sh 不含顶层裸 agency 命令"
fi

# 3. init 分发和 cmd_init 必须完整透传参数。
if grep -Eq '^[[:space:]]*init\)[[:space:]]+cmd_init "\$@"' "$CLI"; then
  ok "init 命令分发完整透传参数"
else
  fail 'init 命令分发未使用 cmd_init "$@"'
fi

if grep -Eq 'init-project\.sh" "\$@"' "$CLI"; then
  ok 'cmd_init 完整透传参数到 init-project.sh'
else
  fail 'cmd_init 未将 "$@" 完整传递给 init-project.sh'
fi

# 4. 检查 scripts/ 下所有 Shell 脚本语法（兼容 macOS 自带 Bash 3.2）。
syntax_bad=0
syntax_count=0
while IFS= read -r file; do
  syntax_count=$((syntax_count+1))
  if ! bash -n "$file" 2> /tmp/agency-shell-syntax.err; then
    fail "Shell 语法错误: ${file#$AGENCY_ROOT/}"
    cat /tmp/agency-shell-syntax.err >&2
    syntax_bad=$((syntax_bad+1))
  fi
done < <(find "$SCRIPT_DIR" -type f -name '*.sh' -print)

if [ "$syntax_bad" -eq 0 ]; then
  ok "Shell 语法检查通过（$syntax_count 个脚本）"
else
  fail "$syntax_bad/$syntax_count 个 Shell 脚本存在语法错误"
fi
rm -f /tmp/agency-shell-syntax.err

echo
echo "PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
