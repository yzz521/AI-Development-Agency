#!/usr/bin/env bash
# 增量门禁自测：用临时 git 仓，不依赖业务仓库。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECK="$ROOT/scripts/check.sh"
fail() { echo "FAIL: $*" >&2; exit 1; }
assert_fail() { "$@" >/tmp/agency-check-out.txt 2>&1 && fail "expected FAIL: $*" || true; grep -q '^FAIL ' /tmp/agency-check-out.txt || fail "no FAIL line: $*"; }
assert_pass() { "$@" >/tmp/agency-check-out.txt 2>&1 || { cat /tmp/agency-check-out.txt >&2; fail "expected PASS: $*"; }; }
assert_has() { grep -q "$2" /tmp/agency-check-out.txt || { cat /tmp/agency-check-out.txt >&2; fail "missing [$2]"; }; }
assert_no() { grep -q "$2" /tmp/agency-check-out.txt && { cat /tmp/agency-check-out.txt >&2; fail "unexpected [$2]"; } || true; }

chmod +x "$CHECK"

tmp="$(mktemp -d)"
cleanup() { rm -rf "$tmp"; }
trap cleanup EXIT

git -C "$tmp" init -q
git -C "$tmp" config user.email "check@test.local"
git -C "$tmp" config user.name "check-selftest"
# 部分环境默认分支名是 master
git -C "$tmp" checkout -q -b main 2>/dev/null || true

mkdir -p "$tmp/src" "$tmp/mapper"
printf '%s\n' 'package demo;' 'public class Ok { void a() {} }' > "$tmp/src/Ok.java"
printf '%s\n' 'SELECT id FROM t' > "$tmp/mapper/OkMapper.xml"
printf '%s\n' 'password: ${DB_PASSWORD}' 'secret: ${APP_SECRET:}' > "$tmp/app.yml"
git -C "$tmp" add src mapper app.yml
git -C "$tmp" commit -q -m init

# 1) 干净工作区应 PASS
assert_pass "$CHECK" --dir "$tmp"
assert_has /tmp/agency-check-out.txt 'result=PASS'

# 2) 新增 Map<String, Object> → FAIL
printf '%s\n' 'package demo;' 'import java.util.Map;' 'class Bad { Map<String, Object> x; }' > "$tmp/src/Ok.java"
assert_fail "$CHECK" --dir "$tmp"
assert_has /tmp/agency-check-out.txt 'java-map-object'
# import 行本身不得当 Map 违规
assert_no /tmp/agency-check-out.txt 'import java.util.Map'

# 3) 只加注释里的 Map → PASS（相对 HEAD 的新增行是注释）
git -C "$tmp" checkout -q -- src/Ok.java
printf '%s\n' 'package demo;' 'public class Ok { void a() {} }' '// Map<String, Object> note' > "$tmp/src/Ok.java"
assert_pass "$CHECK" --dir "$tmp"

# 4) SELECT * → FAIL
git -C "$tmp" checkout -q -- src/Ok.java
printf '%s\n' 'SELECT * FROM t' > "$tmp/mapper/OkMapper.xml"
assert_fail "$CHECK" --dir "$tmp"
assert_has /tmp/agency-check-out.txt 'sql-select-star'

# 5) 明文 password → FAIL；环境变量 → 已在 init PASS
git -C "$tmp" checkout -q -- mapper/OkMapper.xml
printf '%s\n' 'password: hunter2' > "$tmp/app.yml"
assert_fail "$CHECK" --dir "$tmp"
assert_has /tmp/agency-check-out.txt 'secret-hardcoded'

printf '%s\n' 'password: ${DB_PASSWORD}' > "$tmp/app.yml"
assert_pass "$CHECK" --dir "$tmp"

# 6) PathVariable 默认 off
git -C "$tmp" checkout -q -- app.yml
printf '%s\n' 'package demo;' 'class C { void a(@PathVariable String bizId) {} }' > "$tmp/src/Ok.java"
assert_pass "$CHECK" --dir "$tmp"
assert_fail "$CHECK" --dir "$tmp" --enable java-pathvariable
assert_has /tmp/agency-check-out.txt 'java-pathvariable'

# 7) FQCN：import 过关，行内不过关
printf '%s\n' 'package demo;' 'import java.util.List;' 'class C { List<String> a; }' > "$tmp/src/Ok.java"
assert_pass "$CHECK" --dir "$tmp" --enable java-fqcn
printf '%s\n' 'package demo;' 'class C { java.util.List<String> a; }' > "$tmp/src/Ok.java"
assert_fail "$CHECK" --dir "$tmp" --enable java-fqcn
assert_has /tmp/agency-check-out.txt 'java-fqcn'

# 8) 存量 Map 不卡增量；--all 才扫到
git -C "$tmp" checkout -q -- src/Ok.java
printf '%s\n' 'package demo;' 'class Old { java.util.Map<String, Object> x; }' > "$tmp/src/Ok.java"
git -C "$tmp" add src/Ok.java
git -C "$tmp" commit -q -m 'stock map'
printf '%s\n' 'package demo;' 'class Old { java.util.Map<String, Object> x; }' 'class New { void n() {} }' > "$tmp/src/Ok.java"
assert_pass "$CHECK" --dir "$tmp"
assert_fail "$CHECK" --dir "$tmp" --all
assert_has /tmp/agency-check-out.txt 'java-map-object'

# 9) --staged：未暂存的违规不拦；暂存后拦
git -C "$tmp" checkout -q -- src/Ok.java
printf '%s\n' 'package demo;' 'class Old { java.util.Map<String, Object> x; }' 'class Z { Map<String, Object> y; }' > "$tmp/src/Ok.java"
assert_pass "$CHECK" --dir "$tmp" --staged
git -C "$tmp" add src/Ok.java
assert_fail "$CHECK" --dir "$tmp" --staged

# 10) --base 相对上一提交
assert_fail "$CHECK" --dir "$tmp" --base HEAD^
assert_has /tmp/agency-check-out.txt 'java-map-object'

# 11) 拒绝 install 规范库自己
if "$CHECK" --install "$ROOT" >/tmp/agency-check-out.txt 2>&1; then
  fail "install on agency root should fail"
fi
grep -q '规范库自身' /tmp/agency-check-out.txt || fail "install refusal message"

# 12) --install 写入业务仓副本，vendored 脚本可跑
proj="$(mktemp -d)"
git -C "$proj" init -q
git -C "$proj" config user.email "check@test.local"
git -C "$proj" config user.name "check-selftest"
printf '%s\n' 'ok' > "$proj/README"
git -C "$proj" add README
git -C "$proj" commit -q -m init
"$CHECK" --install "$proj" >/tmp/agency-check-out.txt
[ -f "$proj/.agency-check/check.sh" ] || fail "missing vendored check.sh"
[ -f "$proj/.githooks/pre-commit" ] || fail "missing hook"
[ -f "$proj/.github/workflows/agency-check.yml" ] || fail "missing workflow"
[ -f "$proj/agency-check.conf" ] || fail "missing conf"
[ -f "$proj/.agents/skills/agency-check/SKILL.md" ] || fail "missing skill"
grep -q 'name: agency-check' "$proj/.agents/skills/agency-check/SKILL.md" || fail "skill frontmatter"
printf '%s\n' 'class Z { Map<String, Object> y; }' > "$proj/Z.java"
git -C "$proj" add Z.java
assert_fail bash "$proj/.agency-check/check.sh" --dir "$proj" --staged
assert_has /tmp/agency-check-out.txt 'java-map-object'
rm -rf "$proj"

# 13) --list 含默认 on/off
"$CHECK" --list --dir "$tmp" >/tmp/agency-check-out.txt
assert_has /tmp/agency-check-out.txt 'java-map-object'
assert_has /tmp/agency-check-out.txt 'java-pathvariable'

echo "check-selftest OK"
