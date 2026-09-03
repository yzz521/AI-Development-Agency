#!/usr/bin/env bash
# ============================================================
# agency audit — 交叉核对任务单，验证"是否真实按规范执行"
#
# 用法：
#   agency audit [项目目录]
#
# 对项目 .ai/tasks/*.md 逐张任务单核对：
#   1. 必备字段是否填写（ID / 级别 / Agent / 规则 / 读改文件 / 验证 / 反馈）
#   2. "实际读取的文件"是否真实存在（相对项目根路径解析）
#   3. "实际修改的文件"是否真实存在，且与 git 变更 / 文件修改时间交叉核对
#   4. "涉及规则"是否能在项目 .ai/agency 规范库中解析到
#   5. 规则反馈 kind 是否合法
#   6. 验证命令仅列出供人工重跑（audit 不代跑，防报告注入命令）
#
# 局限（诚实声明）：audit 只能证明"汇报内部自洽、文件真实存在、有改动痕迹、回执格式对"，
# 无法证明"AI 真的阅读了规则正文"——那需要看会话里 \`opened=\` 是否对应真实 Read，并人工抽查。
# 退出码：FAIL=0 时返回 0。
# ============================================================
set -uo pipefail

# 解析脚本真实路径（支持符号链接调用）
SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
AGENCY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

project="${1:-$(pwd)}"
project="$(cd "$project" 2>/dev/null && pwd)" || { echo "错误：项目目录不存在: $project" >&2; exit 1; }
TASK_DIR="$project/.ai/tasks"
AGENCY_LINK="$project/.ai/agency"

PASS=0; WARN=0; FAIL=0
ok(){ echo "  ✓ $1"; PASS=$((PASS+1)); }
warn(){ echo "  ⚠ $1"; WARN=$((WARN+1)); }
fail(){ echo "  ✗ $1"; FAIL=$((FAIL+1)); }

# 文件是否可解析（存在或 glob 有匹配）
ref_exists() {
  local base="$1" ref="$2"
  [ -e "$base/$ref" ] && return 0
  if [[ "$ref" == *'*'* ]]; then
    local m; m="$(ls -d "$base"/$ref 2>/dev/null | head -1)"
    [ -n "$m" ] && return 0
  fi
  return 1
}

# 提取某标题下的行（- key: value 或 - [ ] `path`）
section_lines() { # $1=file $2=section标题 $3=行前缀
  awk -v sec="## $2" -v pre="$3" '
    $0==sec {on=1; next}
    /^## / && on {exit}
    on && index($0, pre)==1 {print}
  ' "$1"
}

echo "== 任务单审计：$project =="
if [ ! -d "$TASK_DIR" ] || ! ls "$TASK_DIR"/*.md >/dev/null 2>&1; then
  echo "✗ 未找到任务单（$TASK_DIR）—— 没有任务单 = 没有可审计证据"
  exit 1
fi

for f in "$TASK_DIR"/*.md; do
  name="$(basename "$f")"
  echo
  echo "── $name ──"

  # 1. 必备字段
  id="$(grep -m1 '^- 任务 ID：' "$f" | sed 's/^- 任务 ID：//' | xargs)"
  level="$(grep -m1 '^- 任务级别：' "$f" | sed 's/^- 任务级别：//' | awk '{print $1}')"
  agent="$(grep -m1 '^- 使用 Agent：' "$f" | sed 's/^- 使用 Agent：//' | xargs)"
  wf="$(grep -m1 '^- 使用 Workflow：' "$f" | sed 's/^- 使用 Workflow：//' | xargs)"
  rules="$(grep -m1 '^- 涉及规则：' "$f" | sed 's/^- 涉及规则：//' | xargs)"
  [ -n "$id" ]    && ok "任务 ID: $id"        || fail "缺任务 ID"
  case "$level" in L1|L2|L3) ok "任务级别: $level";; *) fail "任务级别缺失/非法: ${level:-空}";; esac
  [ -n "$agent" ] && ok "使用 Agent: $agent"   || warn "未填写使用 Agent"
  [ -n "$wf" ]    && ok "使用 Workflow: $wf"   || warn "未填写使用 Workflow"

  # 1b. 规范路由回执（证明会话里声称触发了路由；不证明读过原文）
  receipt="$(grep -m1 '^agency-route:' "$f" || grep -m1 'agency-route: matched=' "$f" || true)"
  if [ -z "$receipt" ]; then
    warn "无规范路由回执（会话里可能没触发 agency-route / 未抄进任务单）"
  elif printf '%s' "$receipt" | grep -qE 'agency-route: matched=.+ risk=L[123].*opened='; then
    ok "路由回执: $receipt"
  elif printf '%s' "$receipt" | grep -qE 'agency-route: matched=.+ risk=L[123]'; then
    warn "路由回执缺 opened=（写代码应打开语言/领域原文；探测用 opened=none）: $receipt"
  else
    warn "路由回执格式不完整: $receipt"
  fi

  # 2. 实际读取的文件
  reads="$(section_lines "$f" "实际读取的文件" '- [ ] ')"
  read_n=0
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    ref="$(printf '%s' "$line" | sed -n 's/^- \[ \] `\(.*\)`/\1/p')"
    [ -z "$ref" ] && continue
    read_n=$((read_n+1))
    if ref_exists "$project" "$ref"; then ok "读: $ref"; else fail "读的文件不存在: $ref"; fi
  done <<< "$reads"
  [ "$read_n" -gt 0 ] || warn "未填写实际读取的文件（audit 无从核对）"

  # 3. 实际修改的文件：存在性 + 变更痕迹
  changes="$(section_lines "$f" "实际修改的文件" '- [ ] ')"
  chg_n=0; trace=0
  # 当前 git 变更集（含未跟踪）
  git_set=""
  if git -C "$project" rev-parse --git-dir >/dev/null 2>&1; then
    git_set="$(git -C "$project" status --porcelain | awk '{print $NF}')"
  fi
  task_date="$(printf '%s' "$id" | cut -d- -f1)"
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    ref="$(printf '%s' "$line" | sed -n 's/^- \[ \] `\(.*\)`/\1/p')"
    [ -z "$ref" ] && continue
    chg_n=$((chg_n+1))
    if ! ref_exists "$project" "$ref"; then
      fail "改的文件不存在: $ref"; continue
    fi
    # 变更痕迹：在 git 变更集中，或文件修改日期不早于任务日期
    if printf '%s\n' "$git_set" | grep -qxF "$ref"; then
      ok "改: $ref（在 git 变更集中）"; trace=$((trace+1)); continue
    fi
    if [ -n "$task_date" ]; then
      mtime="$(stat -f %m "$project/$ref" 2>/dev/null || stat -c %Y "$project/$ref" 2>/dev/null)"
      if [ -n "$mtime" ]; then
        # 用日期字符串比较（YYYYMMDD 字典序），避免 epoch/时区歧义
        mdate="$(date -r "$mtime" +%Y%m%d 2>/dev/null || date -d "@$mtime" +%Y%m%d 2>/dev/null)"
        if [[ -n "$mdate" && ( "$mdate" > "$task_date" || "$mdate" == "$task_date" ) ]]; then
          ok "改: $ref（修改日期 $mdate ≥ 任务日期 $task_date）"; trace=$((trace+1)); continue
        fi
      fi
    fi
    warn "改: $ref 存在，但无 git/时间痕迹（可能未提交或可疑）"
  done <<< "$changes"
  [ "$chg_n" -gt 0 ] || warn "未填写实际修改的文件"
  [ "$trace" -gt 0 ] || { [ "$chg_n" -gt 0 ] && warn "所有修改文件均无变更痕迹，请人工核对"; }

  # 4. 涉及规则可解析（经项目 .ai/agency 指向中央规范库）
  if [ -n "$rules" ]; then
    if [ -L "$AGENCY_LINK" ] || [ -d "$AGENCY_LINK" ]; then
      if ref_exists "$AGENCY_LINK" "$rules"; then ok "规则可解析: $rules"; else fail "规则不存在: $rules"; fi
    else
      warn "项目缺少 .ai/agency 入口，无法核对规则引用（$rules）"
    fi
  else
    warn "未填写涉及规则"
  fi

  # 5. 规则反馈 kind 合法
  kind="$(section_lines "$f" "规则反馈" '- kind：' | sed 's/^- kind：//' | xargs)"
  case "$kind" in
    rule_applied|rule_violated|rule_gap|rule_stale|workflow_ok|workflow_gap|context_gap)
      ok "规则反馈: $kind";;
    ""|无|无。)
      [ "$level" = "L3" ] && warn "L3 未填写规则反馈（有缺口才必须写）" || ok "规则反馈：无（L1/L2 允许）";;
    *) fail "非法规则反馈 kind: $kind";;
  esac

  # 6. 验证命令（只列出，供人工重跑）
  cmd="$(section_lines "$f" "验证" '- 命令：' | sed 's/^- 命令：//' | xargs)"
  [ -n "$cmd" ] && ok "验证命令（人工可重跑）: $cmd" || warn "未填写验证命令"
done

echo
echo "PASS=$PASS WARN=$WARN FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
