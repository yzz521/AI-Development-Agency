#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; AGENCY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"; PROJECT_DIR="${1:-}"
[ -n "$PROJECT_DIR" ] || { echo "用法: $0 <项目目录>"; exit 1; }
PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd)" || { echo "错误：项目不存在"; exit 1; }
LINK="$PROJECT_DIR/.ai/agency"; PASS=0; WARN=0; FAIL=0
ok(){ echo "✓ $1"; PASS=$((PASS+1)); }; warn(){ echo "⚠ $1"; WARN=$((WARN+1)); }; fail(){ echo "✗ $1"; FAIL=$((FAIL+1)); }
if [ -f "$PROJECT_DIR/AGENTS.md" ]; then
  ok "AGENTS.md"
  grep -q 'agency-router:begin' "$PROJECT_DIR/AGENTS.md" && ok "AGENTS.md 含规范路由段" || warn "AGENTS.md 无规范路由段（agency route --install 可写入）"
else
  fail "缺少 AGENTS.md"
fi
[ -f "$PROJECT_DIR/.cursor/rules/agency-router.mdc" ] && ok "Cursor 自动路由规则" || warn "无 .cursor/rules/agency-router.mdc（仅 Cursor 增益）"
[ -f "$PROJECT_DIR/.agents/skills/agency-route/SKILL.md" ] && ok "agency-route 技能" || warn "无 .agents/skills/agency-route（技能自动匹配不可用）"
if [ -L "$LINK" ]; then
  resolved="$(cd "$(dirname "$LINK")" && cd "$(readlink "$LINK")" 2>/dev/null && pwd || true)"
  [ "$resolved" = "$AGENCY_ROOT" ] && ok ".ai/agency 正确" || fail ".ai/agency 指向错误"
elif [ -e "$LINK" ]; then fail ".ai/agency 不是软链接"; else fail "缺少 .ai/agency"; fi
[ -f "$LINK/AGENTS.md" ] && ok "Agency AGENTS.md" || fail "Agency AGENTS.md 不可访问"
[ -d "$LINK/agents" ] && ok "agents/" || fail "agents/ 不可访问"
[ -d "$LINK/rules" ] && ok "rules/" || fail "rules/ 不可访问"
[ -d "$LINK/workflows" ] && ok "workflows/" || fail "workflows/ 不可访问"
[ -f "$PROJECT_DIR/pom.xml" ] || [ -f "$PROJECT_DIR/build.gradle" ] || [ -f "$PROJECT_DIR/build.gradle.kts" ] && ok "Java 构建文件" || warn "未检测到 Maven/Gradle 根文件"
if [ -f "$PROJECT_DIR/.agency-check/check.sh" ] || [ -f "$PROJECT_DIR/agency-check.conf" ]; then
  ok "增量门禁文件"
  if [ -f "$PROJECT_DIR/.githooks/pre-commit" ]; then
    hp="$(git -C "$PROJECT_DIR" config --get core.hooksPath 2>/dev/null || true)"
    if [ "$hp" = ".githooks" ]; then
      ok "core.hooksPath=.githooks"
    else
      warn "有 .githooks/pre-commit 但未 git config core.hooksPath .githooks（CI 仍可拦）"
    fi
  else
    warn "有门禁配置但无 .githooks/pre-commit"
  fi
  [ -f "$PROJECT_DIR/.github/workflows/agency-check.yml" ] && ok "CI agency-check.yml" || warn "无 .github/workflows/agency-check.yml"
else
  warn "未安装增量门禁（需要时: agency check --install；不绑进 init）"
fi
echo; echo "PASS=$PASS WARN=$WARN FAIL=$FAIL"; [ "$FAIL" -eq 0 ]
