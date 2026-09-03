#!/usr/bin/env bash
# 规范路由自测：不依赖业务仓库，只验证匹配与摘要抽取。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ROUTE="$ROOT/scripts/route.sh"
fail() { echo "FAIL: $*" >&2; exit 1; }
assert_has() { printf '%s\n' "$1" | grep -q "$2" || fail "missing [$2] in output"; }
assert_no() { printf '%s\n' "$1" | grep -q "$2" && fail "unexpected [$2] in output" || true; }

chmod +x "$ROUTE"

out="$("$ROUTE" --dir "$ROOT" --task "x" --files Foo.java --stack java)"
assert_has "$out" "rules/java.md"
assert_has "$out" "java-developer"
assert_has "$out" "Controller 接收完整 DTO"
assert_no "$out" "rules/react.md"
assert_no "$out" "rules/vue.md"

out="$("$ROUTE" --dir "$ROOT" --task "x" --files App.vue --stack vue)"
assert_has "$out" "rules/vue.md"
assert_has "$out" "vue-developer"
assert_no "$out" "rules/java.md"

out="$("$ROUTE" --dir "$ROOT" --task "x" --files src/main/resources/application-prod.yml --stack java)"
assert_has "$out" "spring-boot-configuration.md"

out="$("$ROUTE" --dir "$ROOT" --task "给医保审核加 DRG 分组查询" --files Foo.java --stack java,healthcare)"
assert_has "$out" "rules/healthcare.md"
assert_has "$out" "rules/java.md"
assert_has "$out" "risk: L3"

out="$("$ROUTE" --dir "$ROOT" --task "修一个 NPE bug" --stack java)"
assert_has "$out" "matched: core,bug,java"
assert_has "$out" "bug-fixing.md"

out="$("$ROUTE" --dir "$ROOT" --task "无关闲聊" --stack java)"
assert_has "$out" "rules/global.md"
assert_has "$out" "rules/java.md"

# 二次 install 不得因路由段里出现 Vue/React 字样而把全栈摘要写进去
tmp="$(mktemp -d)"
echo '<project></project>' > "$tmp/pom.xml"
printf '%s\n' '# demo' '后端：Java Spring Boot' > "$tmp/AGENTS.md"
"$ROUTE" --install "$tmp" >/dev/null
"$ROUTE" --install "$tmp" >/dev/null
grep -q '^### rules/java.md$' "$tmp/AGENTS.md" || { rm -rf "$tmp"; fail "install 未写入 java 摘要"; }
if grep -q '^### rules/react.md$' "$tmp/AGENTS.md"; then rm -rf "$tmp"; fail "java 项目不该写入 react 摘要"; fi
if grep -q '^### rules/vue.md$' "$tmp/AGENTS.md"; then rm -rf "$tmp"; fail "java 项目不该写入 vue 摘要"; fi
grep -q '检测技术栈：java$' "$tmp/AGENTS.md" || { rm -rf "$tmp"; fail "二次 install 技术栈被路由段污染"; }
rm -rf "$tmp"

echo "route-selftest OK"
