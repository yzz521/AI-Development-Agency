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
for d in agents rules workflows context contracts artifacts validation evolution templates scripts; do
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

echo
echo "PASS=$PASS WARN=$WARN FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
