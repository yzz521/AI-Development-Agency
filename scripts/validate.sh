#!/usr/bin/env bash
# ============================================================
# agency validate — 校验规范库完整性（自进化：守门）
#
# 作用：
#   - 保证“规则引用”不悬空（Agent 必读、Workflow Agent、AGENTS.md 路由）
#   - 保证 Agent front matter 完整
#   - 保证提案 / 反馈符合格式
#   - 防止自进化合并时破坏规范库结构
#
# 可独立运行，也可接入 CI（.github/workflows/validate.yml）。
# 退出码：FAIL=0 时返回 0。
# ============================================================
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENCY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$AGENCY_ROOT"

PASS=0; WARN=0; FAIL=0
ok(){ echo "✓ $1"; PASS=$((PASS+1)); }
warn(){ echo "⚠ $1"; WARN=$((WARN+1)); }
fail(){ echo "✗ $1"; FAIL=$((FAIL+1)); }

# 引用是否可解析：文件 / 目录 / glob 通配（如 contracts/*.md、agents/**/*.md）
ref_ok() {
  local ref="$1"
  [ -e "$ref" ] && return 0
  [ -d "$ref" ] && return 0
  if [[ "$ref" == *'*'* ]]; then
    local matches; matches="$(ls -d $ref 2>/dev/null | head -1)"
    [ -n "$matches" ] && return 0
  fi
  return 1
}

echo "== 校验规范库：$AGENCY_ROOT =="

# 1. 结构完整性
for d in agents rules workflows context contracts artifacts validation evolution templates scripts routes skills checks; do
  [ -d "$d" ] && ok "目录 $d/" || fail "缺少目录 $d/"
done
[ -f AGENTS.md ] && ok "AGENTS.md" || fail "缺少 AGENTS.md"
[ -f CHANGELOG.md ] && ok "CHANGELOG.md" || fail "缺少 CHANGELOG.md"

# 2. Agent 必读引用可解析
echo "── Agent 必读引用 ──"
missing_refs=0
while IFS= read -r f; do
  while IFS= read -r ref; do
    case "$ref" in
      AGENTS.md) [ -f AGENTS.md ] || { fail "$f 引用缺失: AGENTS.md"; missing_refs=$((missing_refs+1)); };;
      agents/*|rules/*|context/*|workflows/*|contracts/*|artifacts/*|validation/*|templates/*)
        ref_ok "$ref" || { fail "$f 引用缺失: $ref"; missing_refs=$((missing_refs+1)); };;
    esac
  done < <(grep -oE '\`[^\`]+\`' "$f" | tr -d '`' | sort -u)
done < <(find agents -name '*.md')
[ "$missing_refs" -eq 0 ] && ok "Agent 必读引用全部可解析"

# 3. Workflow 的 Agent 引用可解析
echo "── Workflow Agent 引用 ──"
wf_missing=0
while IFS= read -r f; do
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    if ! find agents -name "$name.md" | grep -q .; then
      fail "$f 引用的 Agent 不存在: $name"; wf_missing=$((wf_missing+1))
    fi
  done < <(grep -oE 'Agent: \`[^\`]+\`' "$f" | sed -E 's/Agent: \`([^\`]+)\`/\1/')
done < <(find workflows -name '*.md')
[ "$wf_missing" -eq 0 ] && ok "Workflow Agent 引用全部可解析"

# 4. AGENTS.md 路由引用可解析
echo "── AGENTS.md 引用 ──"
agents_missing=0
while IFS= read -r ref; do
  case "$ref" in
    agents/*|rules/*|context/*|workflows/*|contracts/*|artifacts/*|validation/*|templates/*)
      ref_ok "$ref" || { fail "AGENTS.md 引用缺失: $ref"; agents_missing=$((agents_missing+1)); };;
  esac
done < <(grep -oE '\`[^\`]+\`' AGENTS.md | tr -d '`' | sort -u)
[ "$agents_missing" -eq 0 ] && ok "AGENTS.md 引用全部可解析"

# 5. Agent front matter
echo "── Agent front matter ──"
fm_bad=0
while IFS= read -r f; do
  head -1 "$f" | grep -q '^---$' || { fail "$f 缺少 front matter"; fm_bad=$((fm_bad+1)); continue; }
  grep -qE '^name:' "$f" || { fail "$f front matter 缺 name"; fm_bad=$((fm_bad+1)); }
  grep -qE '^description:' "$f" || { fail "$f front matter 缺 description"; fm_bad=$((fm_bad+1)); }
done < <(find agents -name '*.md')
[ "$fm_bad" -eq 0 ] && ok "Agent front matter 全部完整"

# 6. Agent 名称唯一性（防跨目录重名）
dup="$(find agents -name '*.md' -exec basename {} \; | sort | uniq -d)"
if [ -n "$dup" ]; then for d in $dup; do fail "Agent 重名: $d"; done; else ok "Agent 名称唯一"; fi

# 7. 提案状态约束
echo "── 提案状态 ──"
if [ -d evolution/proposals ] && ls evolution/proposals/*.md >/dev/null 2>&1; then
  for f in evolution/proposals/*.md; do
    st="$(grep -m1 '^status:' "$f" | cut -d' ' -f2- | tr -d ' ')"
    case "$st" in
      draft|review) ;;
      merged|rejected) fail "$(basename "$f") 状态 $st 应移入 evolution/archive/";;
      *) fail "$(basename "$f") 非法状态: $st";;
    esac
    for key in id title type status; do
      grep -qE "^$key:" "$f" || fail "$(basename "$f") 缺 front matter: $key"
    done
  done
else
  ok "无待评审提案"
fi

# 8. 反馈格式
echo "── 反馈格式 ──"
fb_bad=0
if [ -d evolution/feedback ] && ls evolution/feedback/*.md >/dev/null 2>&1; then
  while IFS= read -r f; do
    while IFS= read -r kind; do
      case "$kind" in
        rule_applied|rule_violated|rule_gap|rule_stale|workflow_ok|workflow_gap|context_gap) ;;
        *) fail "$(basename "$f") 非法反馈 kind: $kind"; fb_bad=$((fb_bad+1));;
      esac
    done < <(grep -oE '^- kind: [a-z_]+' "$f" | awk '{print $3}')
  done < <(find evolution/feedback -name '*.md')
else
  ok "暂无反馈记录"
fi
[ "$fb_bad" -eq 0 ] && ok "反馈 kind 全部合法"

# 9. 路由表
echo "── 规范路由 ──"
if [ -f routes/table.tsv ]; then
  ok "routes/table.tsv"
else
  fail "缺少 routes/table.tsv"
fi
grep -q 'agency-router:begin' AGENTS.md && ok "AGENTS.md 含路由段标记" || fail "AGENTS.md 缺 agency-router 标记"
grep -q 'agency-pin:begin' AGENTS.md && ok "AGENTS.md 含钉死段标记" || fail "AGENTS.md 缺 agency-pin 标记"
[ -f skills/agency-route/SKILL.md ] && ok "skills/agency-route" || fail "缺少 agency-route 技能"
[ -f contracts/route-contract.md ] && ok "contracts/route-contract.md" || fail "缺少路由契约"

route_bad=0
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in \#*|"") continue;; esac
  IFS='|' read -r type id pattern agents rules wf risk st hint <<EOF
$line
EOF
  [ -n "$id" ] || { fail "路由表空 id: $line"; route_bad=$((route_bad+1)); continue; }
  case "$type" in always|file|keyword) ;; *) fail "路由表非法 type: $type ($id)"; route_bad=$((route_bad+1));; esac
  rest="${rules},"
  while [ -n "$rest" ]; do
    ref="${rest%%,*}"; rest="${rest#*,}"
    ref="$(printf '%s' "$ref" | sed 's/^ *//;s/ *$//')"
    [ -z "$ref" ] && continue
    [ -f "$ref" ] || { fail "路由表 $id 引用缺失: $ref"; route_bad=$((route_bad+1)); }
  done
  rest="${agents},"
  while [ -n "$rest" ]; do
    ag="${rest%%,*}"; rest="${rest#*,}"
    ag="$(printf '%s' "$ag" | sed 's/^ *//;s/ *$//')"
    [ -z "$ag" ] && continue
    find agents -name "$ag.md" | grep -q . || { fail "路由表 $id Agent 不存在: $ag"; route_bad=$((route_bad+1)); }
  done
  if [ -n "$wf" ] && [ ! -f "$wf" ]; then
    fail "路由表 $id workflow 缺失: $wf"; route_bad=$((route_bad+1))
  fi
done < routes/table.tsv
[ "$route_bad" -eq 0 ] && ok "路由表引用全部可解析"

# 10. 被路由规则必须有摘要区（evolution.md 除外）
sum_bad=0
while IFS= read -r f; do
  case "$f" in rules/evolution.md) continue;; esac
  grep -q '^## 摘要（注入用）$' "$f" || { fail "$f 缺少 ## 摘要（注入用）"; sum_bad=$((sum_bad+1)); }
done < <(find rules -name '*.md')
[ "$sum_bad" -eq 0 ] && ok "被分发规则均含摘要区"

# 11. 路由自测
if bash scripts/route-selftest.sh >/tmp/agency-route-selftest.log 2>&1; then
  ok "route-selftest"
else
  fail "route-selftest 失败（见 /tmp/agency-route-selftest.log）"
  cat /tmp/agency-route-selftest.log >&2 || true
fi

# 12. 增量门禁 catalog + 技能 + 契约
echo "── 增量门禁 ──"
[ -f checks/catalog.tsv ] && ok "checks/catalog.tsv" || fail "缺少 checks/catalog.tsv"
[ -f scripts/check.sh ] && ok "scripts/check.sh" || fail "缺少 scripts/check.sh"
[ -f contracts/check-contract.md ] && ok "contracts/check-contract.md" || fail "缺少门禁契约"
[ -f skills/agency-check/SKILL.md ] && ok "skills/agency-check" || fail "缺少 agency-check 技能"
[ -f templates/githooks/pre-commit ] && ok "templates/githooks/pre-commit" || fail "缺少 hook 模板"
[ -f templates/github-workflows/agency-check.yml ] && ok "templates/github-workflows/agency-check.yml" || fail "缺少 CI 模板"
[ -f templates/agency-check.conf ] && ok "templates/agency-check.conf" || fail "缺少 agency-check.conf 模板"
grep -q '^name: agency-check$' skills/agency-check/SKILL.md && ok "agency-check frontmatter" || fail "agency-check 缺 name frontmatter"

check_bad=0
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in \#*|"") continue;; esac
  IFS='|' read -r id default severity globs engine rule message <<EOF
$line
EOF
  [ -n "$id" ] || { fail "门禁表空 id: $line"; check_bad=$((check_bad+1)); continue; }
  case "$default" in on|off) ;; *) fail "门禁表 $id 非法 default: $default"; check_bad=$((check_bad+1));; esac
  [ -f "$rule" ] || { fail "门禁表 $id 规则缺失: $rule"; check_bad=$((check_bad+1)); }
  grep -q "${engine})" scripts/check.sh || { fail "门禁表 $id engine 未实现: $engine"; check_bad=$((check_bad+1)); }
done < checks/catalog.tsv
[ "$check_bad" -eq 0 ] && ok "门禁表引用与 engine 可解析"

if bash scripts/check-selftest.sh >/tmp/agency-check-selftest.log 2>&1; then
  ok "check-selftest"
else
  fail "check-selftest 失败（见 /tmp/agency-check-selftest.log）"
  cat /tmp/agency-check-selftest.log >&2 || true
fi

echo
echo "PASS=$PASS WARN=$WARN FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
