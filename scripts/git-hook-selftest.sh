#!/usr/bin/env bash
# commit-msg 钩子自测：不依赖业务仓库。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$ROOT/templates/githooks/commit-msg"
fail() { echo "FAIL: $*" >&2; exit 1; }

pass() {
  local f
  f="$(mktemp)"
  printf '%s\n' "$1" > "$f"
  if ! sh "$HOOK" "$f" >/dev/null 2>&1; then
    rm -f "$f"
    fail "should accept: $1"
  fi
  rm -f "$f"
}

reject() {
  local f
  f="$(mktemp)"
  printf '%s\n' "$1" > "$f"
  if sh "$HOOK" "$f" >/dev/null 2>&1; then
    rm -f "$f"
    fail "should reject: $1"
  fi
  rm -f "$f"
}

[ -f "$HOOK" ] || fail "missing $HOOK"

pass 'feat(git): add conventional commits'
pass 'fix: 修复登录超时'
pass 'docs(readme): 更新说明'
pass 'feat(api)!: drop unused field'
pass "Merge branch 'x' into main"
pass 'Revert "feat(git): add conventional commits"'
pass 'chore: bump agency check template'

reject 'fix stuff'
reject 'update'
reject '改一下'
reject 'feat:'
reject 'unknown: hello'
reject 'FEAT: uppercase type'

echo "git-hook-selftest OK"
