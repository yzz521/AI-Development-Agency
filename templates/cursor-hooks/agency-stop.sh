#!/usr/bin/env bash
# ============================================================
# Cursor stop hook —— Agent 想结束一轮时跑增量门禁，有违规就把它拽回来
#
# 由 `agency check --install` 写入项目 .cursor/hooks/。
# 依赖项目内 .agency-check/check.sh（--install 已写入，可提交）。
#
# 设计取舍：
#   - 只在有未提交改动时才跑，纯问答/只读任务不触发。
#   - 用 followup_message 而不是 exit 2：让 Agent 收到"去修"的指令并继续，
#     而不是硬失败把这一轮打断。
#   - 只有 check 返回 1（有违规）才介入；环境错误（返回 2）静默放行，不打扰。
#   - 循环上限由 .cursor/hooks.json 的 loop_limit 控制（默认 2）。
# ============================================================
set -uo pipefail

ROOT="${CURSOR_PROJECT_DIR:-$(pwd)}"

# 读掉 stdin（Cursor 会传 JSON），避免上游写管道时阻塞
cat > /dev/null 2>&1 || true

# 优先用项目内副本（可提交，同事 clone 即可用）；退回 .ai/agency
CHECK=""
if [ -f "$ROOT/.agency-check/check.sh" ]; then
  CHECK="$ROOT/.agency-check/check.sh"
elif [ -f "$ROOT/.ai/agency/scripts/check.sh" ]; then
  CHECK="$ROOT/.ai/agency/scripts/check.sh"
fi
[ -n "$CHECK" ] || exit 0

# 没有未提交改动就放行
if command -v git >/dev/null 2>&1; then
  [ -n "$(git -C "$ROOT" status --porcelain 2>/dev/null)" ] || exit 0
fi

OUT="$(bash "$CHECK" 2>&1)"
RC=$?

# 只有"存在违规"才把 Agent 拽回来；用法/环境错误不打扰
[ "$RC" -eq 1 ] || exit 0

MSG="增量门禁（agency check）发现违规，不能就这么结束。请先修复以下问题，再重新运行 agency check 确认清零：

$OUT

若确认是误报，把该行写进 agency-check.conf 关闭对应检查，或在此说明理由后重跑。"

# 手工转义 JSON（零依赖，不引 jq / python）
ESC="$(printf '%s' "$MSG" | sed 's/\\/\\\\/g; s/"/\\"/g' | awk '{printf "%s\\n", $0}')"
printf '{"followup_message":"%s"}\n' "$ESC"
exit 0
