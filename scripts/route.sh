#!/usr/bin/env bash
# ============================================================
# agency route — 任务/文件 → 规范摘要（规范路由）
#
# 用法：
#   agency route [--task "..."] [--files a,b] [--dir 项目目录]
#   agency route --install [项目目录] [--stack java,vue,...]
#   agency route --refresh-docs
#
# 设计：
#   用户不必记本命令。提示词自动路由靠 AGENTS.md / Cursor rule / 技能。
#   本命令是同一张表的检查器，以及把压缩摘要写入业务仓库的安装器。
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENCY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TABLE="$AGENCY_ROOT/routes/table.tsv"
ROUTER_BEGIN="<!-- agency-router:begin -->"
ROUTER_END="<!-- agency-router:end -->"
PIN_BEGIN="<!-- agency-pin:begin -->"
PIN_END="<!-- agency-pin:end -->"

usage() { sed -n '3,16p' "$0" | sed 's/^# \{0,1\}//'; }

# ---------- 基础工具（bash 3.2）----------

tolower() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

csv_has() {
  local csv="$1" item="$2" x rest
  [ -z "$csv" ] && return 1
  rest="$csv,"
  while [ -n "$rest" ]; do
    x="${rest%%,*}"; rest="${rest#*,}"
    x="$(printf '%s' "$x" | sed 's/^ *//;s/ *$//')"
    [ "$x" = "$item" ] && return 0
  done
  return 1
}

add_csv() {
  # $1=current csv, $2=item → stdout new csv
  local cur="$1" item="$2"
  [ -z "$item" ] && { printf '%s' "$cur"; return 0; }
  if [ -z "$cur" ]; then printf '%s' "$item"; return 0; fi
  csv_has "$cur" "$item" && { printf '%s' "$cur"; return 0; }
  printf '%s,%s' "$cur" "$item"
}

add_csv_list() {
  local cur="$1" list="$2" item rest
  [ -z "$list" ] && { printf '%s' "$cur"; return 0; }
  rest="$list,"
  while [ -n "$rest" ]; do
    item="${rest%%,*}"; rest="${rest#*,}"
    item="$(printf '%s' "$item" | sed 's/^ *//;s/ *$//')"
    [ -z "$item" ] && continue
    cur="$(add_csv "$cur" "$item")"
  done
  printf '%s' "$cur"
}

risk_rank() {
  case "$1" in
    L3|l3) echo 3;;
    L2|l2) echo 2;;
    L1|l1) echo 1;;
    *) echo 0;;
  esac
}

risk_from_rank() {
  case "$1" in
    3) echo L3;;
    2) echo L2;;
    1) echo L1;;
    *) echo "";;
  esac
}

extract_summary() {
  local file="$1"
  [ -f "$file" ] || return 1
  awk '
    $0 == "## 摘要（注入用）" {on=1; next}
    on && /^## / {exit}
    on && /^---$/ {exit}
    on {print}
  ' "$file" | sed '/^$/d'
}

file_matches_pattern() {
  local path="$1" glob="$2"
  local base="${path##*/}"
  glob="$(printf '%s' "$glob" | sed 's/^ *//;s/ *$//')"
  [ -z "$glob" ] && return 1
  case "$glob" in
    */*)
      # path glob: treat * as wildcard via case
      case "/$path/" in
        */mapper/*) [ "$glob" = "**/mapper/**" ] && return 0;;
      esac
      case "$path" in
        $glob) return 0;;
      esac
      ;;
  esac
  case "$base" in
    $glob) return 0;;
  esac
  return 1
}

file_matches_any() {
  local path="$1" patterns="$2" rest p
  rest="$patterns,"
  while [ -n "$rest" ]; do
    p="${rest%%,*}"; rest="${rest#*,}"
    file_matches_pattern "$path" "$p" && return 0
  done
  return 1
}

task_matches_keywords() {
  local task_lc="$1" kws="$2" rest kw
  rest="$kws,"
  while [ -n "$rest" ]; do
    kw="${rest%%,*}"; rest="${rest#*,}"
    kw="$(printf '%s' "$kw" | sed 's/^ *//;s/ *$//')"
    [ -z "$kw" ] && continue
    kw="$(tolower "$kw")"
    case "$task_lc" in
      *"$kw"*) return 0;;
    esac
  done
  return 1
}

# ---------- 项目技术栈探测 ----------

detect_stack() {
  local dir="$1"
  local out=""
  [ -d "$dir" ] || { echo ""; return 0; }

  first_file() {
    find "$dir" -maxdepth 5 \( -path '*/.git/*' -o -path '*/node_modules/*' -o -path '*/.venv/*' -o -path '*/venv/*' \) -prune -o \( "$@" \) -print -quit 2>/dev/null
  }

  if [ -f "$dir/pom.xml" ] || [ -f "$dir/build.gradle" ] || [ -f "$dir/build.gradle.kts" ]; then
    out="$(add_csv "$out" java)"
  elif [ -n "$(first_file -name '*.java')" ]; then
    out="$(add_csv "$out" java)"
  fi

  if [ -n "$(first_file -name '*.vue')" ]; then
    out="$(add_csv "$out" vue)"
  elif [ -f "$dir/package.json" ] && grep -q '"vue"' "$dir/package.json" 2>/dev/null; then
    out="$(add_csv "$out" vue)"
  fi

  if [ -f "$dir/package.json" ] && grep -q '"react"' "$dir/package.json" 2>/dev/null; then
    out="$(add_csv "$out" react)"
  elif [ -n "$(first_file -name '*.tsx' -o -name '*.jsx')" ]; then
    out="$(add_csv "$out" react)"
  fi

  if [ -f "$dir/pyproject.toml" ] || [ -f "$dir/requirements.txt" ]; then
    out="$(add_csv "$out" python)"
  elif [ -n "$(first_file -name '*.py')" ]; then
    out="$(add_csv "$out" python)"
  fi

  if [ -n "$(first_file -name '*.sql' -o -name '*Mapper.xml' -o -name '*mapper.xml')" ]; then
    out="$(add_csv "$out" sqlserver)"
  fi

  if [ -f "$dir/AGENTS.md" ]; then
    local agents_md
    agents_md="$(awk '/agency-router:begin/{s=1;next} /agency-router:end/{s=0;next} !s{print}' "$dir/AGENTS.md")"
    echo "$agents_md" | grep -qiE 'SQL Server|sqlserver|T-SQL' && out="$(add_csv "$out" sqlserver)"
    echo "$agents_md" | grep -qiE '医保|DRG|DIP|医疗|病案' && out="$(add_csv "$out" healthcare)"
    echo "$agents_md" | grep -qiE 'RAG|OCR|LLM|embedding|向量' && out="$(add_csv "$out" ai)"
    echo "$agents_md" | grep -qiE 'Java|Spring' && out="$(add_csv "$out" java)"
    echo "$agents_md" | grep -qiE 'Vue' && out="$(add_csv "$out" vue)"
    echo "$agents_md" | grep -qiE 'React' && out="$(add_csv "$out" react)"
    echo "$agents_md" | grep -qiE 'Python' && out="$(add_csv "$out" python)"
  fi

  printf '%s' "$out"
}

# ---------- 读表并匹配 ----------

# 输出匹配行：原样 TSV 行（不含注释）
# 使用全局变量太乱；通过 stdout 收集 id 列表，再二次扫描。
# 这里直接一次扫描，把结果写入临时文件。

match_routes() {
  local task="$1" files="$2" stack="$3" out_file="$4"
  local task_lc; task_lc="$(tolower "$task")"
  local matched_ids="" file_matched="" line type id pattern agents rules wf risk st hint
  : > "$out_file"

  # 1) always 全收；file 按路径；keyword 按任务（再按 stack 过滤）
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      \#*|"") continue;;
    esac
    IFS='|' read -r type id pattern agents rules wf risk st hint <<EOF
$line
EOF
    [ -n "$id" ] || continue
    case "$type" in
      always)
        echo "$line" >> "$out_file"
        matched_ids="$(add_csv "$matched_ids" "$id")"
        ;;
      file)
        local rest="$files," f hit=0
        [ -z "$files" ] && continue
        while [ -n "$rest" ]; do
          f="${rest%%,*}"; rest="${rest#*,}"
          f="$(printf '%s' "$f" | sed 's/^ *//;s/ *$//')"
          [ -z "$f" ] && continue
          if file_matches_any "$f" "$pattern"; then hit=1; break; fi
        done
        if [ "$hit" = 1 ]; then
          echo "$line" >> "$out_file"
          matched_ids="$(add_csv "$matched_ids" "$id")"
          file_matched=1
        fi
        ;;
      keyword)
        [ -z "$task" ] && continue
        task_matches_keywords "$task_lc" "$pattern" || continue
        if [ "$st" != "any" ] && [ -n "$stack" ] && ! csv_has "$stack" "$st"; then
          continue
        fi
        echo "$line" >> "$out_file"
        matched_ids="$(add_csv "$matched_ids" "$id")"
        ;;
    esac
  done < "$TABLE"

  # 2) 回退：没有命中任何 file 行时，只套该技术栈的主 file 行（java/vue/react/python/sql）
  #    不把 spring-boot 等加细规则塞进「普通任务」
  if [ -z "$file_matched" ] && [ -n "$stack" ]; then
    local want_ids="" s pid
    local rest="$stack,"
    while [ -n "$rest" ]; do
      s="${rest%%,*}"; rest="${rest#*,}"
      s="$(printf '%s' "$s" | sed 's/^ *//;s/ *$//')"
      case "$s" in
        java) pid=java;;
        vue) pid=vue;;
        react) pid=react;;
        python) pid=python;;
        sqlserver) pid=sql;;
        *) pid="";;
      esac
      [ -n "$pid" ] && want_ids="$(add_csv "$want_ids" "$pid")"
    done
    while IFS= read -r line || [ -n "$line" ]; do
      case "$line" in \#*|"") continue;; esac
      IFS='|' read -r type id pattern agents rules wf risk st hint <<EOF
$line
EOF
      [ "$type" = file ] || continue
      csv_has "$matched_ids" "$id" && continue
      csv_has "$want_ids" "$id" || continue
      echo "$line" >> "$out_file"
      matched_ids="$(add_csv "$matched_ids" "$id")"
    done < "$TABLE"
  fi
}

collect_from_matches() {
  local match_file="$1"
  AGENTS_OUT=""; RULES_OUT=""; WFS_OUT=""; HINTS_OUT=""; RISK_RANK=0; IDS_OUT=""
  local line type id pattern agents rules wf risk st hint r
  while IFS= read -r line || [ -n "$line" ]; do
    [ -z "$line" ] && continue
    IFS='|' read -r type id pattern agents rules wf risk st hint <<EOF
$line
EOF
    IDS_OUT="$(add_csv "$IDS_OUT" "$id")"
    AGENTS_OUT="$(add_csv_list "$AGENTS_OUT" "$agents")"
    RULES_OUT="$(add_csv_list "$RULES_OUT" "$rules")"
    [ -n "$wf" ] && WFS_OUT="$(add_csv "$WFS_OUT" "$wf")"
    r="$(risk_rank "$risk")"
    [ "$r" -gt "$RISK_RANK" ] && RISK_RANK="$r"
    [ -n "$hint" ] && HINTS_OUT="${HINTS_OUT:+$HINTS_OUT
}# $id
- $hint"
  done < "$match_file"

  WF_OUT=""
  if csv_has "$WFS_OUT" "workflows/bug-fixing.md"; then
    WF_OUT="workflows/bug-fixing.md"
  elif csv_has "$WFS_OUT" "workflows/database-change.md"; then
    WF_OUT="workflows/database-change.md"
  else
    local n=0 rest wf
    rest="${WFS_OUT},"
    while [ -n "$rest" ]; do
      wf="${rest%%,*}"; rest="${rest#*,}"
      [ -z "$wf" ] && continue
      n=$((n+1))
      WF_OUT="$wf"
    done
    [ "$n" -gt 1 ] && WF_OUT="workflows/feature-development.md"
  fi
  RISK_OUT="$(risk_from_rank "$RISK_RANK")"
}

print_summaries() {
  local rules="$1" rest item file sum
  rest="${rules},"
  while [ -n "$rest" ]; do
    item="${rest%%,*}"; rest="${rest#*,}"
    item="$(printf '%s' "$item" | sed 's/^ *//;s/ *$//')"
    [ -z "$item" ] && continue
    file="$AGENCY_ROOT/$item"
    echo
    echo "### $item"
    if [ -f "$file" ]; then
      sum="$(extract_summary "$file" || true)"
      if [ -n "$sum" ]; then
        printf '%s\n' "$sum"
      else
        echo "- （无摘要区，请读原文）"
      fi
    else
      echo "- （原文不在本机；按路由 hint 执行）"
    fi
    echo
    echo "原文：$item"
  done
}

print_route_report() {
  local dir="$1" task="$2" files="$3" stack="$4" match_file="$5"
  collect_from_matches "$match_file"
  echo "══ agency route ══"
  echo "agency-route: matched=${IDS_OUT:-none} risk=${RISK_OUT:-L1} rules=${RULES_OUT:-} opened=suggest:${RULES_OUT:-none} source=cli"
  echo "project: $dir"
  [ -n "$task" ] && echo "task: $task"
  [ -n "$files" ] && echo "files: $files"
  echo "stack: ${stack:-unknown}"
  echo "matched: ${IDS_OUT:-none}"
  echo "risk: ${RISK_OUT:-L1}"
  echo
  echo "agents:"
  if [ -n "$AGENTS_OUT" ]; then
    local rest="$AGENTS_OUT," a
    while [ -n "$rest" ]; do
      a="${rest%%,*}"; rest="${rest#*,}"
      [ -z "$a" ] && continue
      echo "  - $a"
    done
  else
    echo "  - （按任务继续选最小必要角色，不必加载全部）"
  fi
  echo
  echo "workflow: ${WF_OUT:-workflows/feature-development.md}"
  echo
  echo "rules:"
  if [ -n "$RULES_OUT" ]; then
    local rest="$RULES_OUT," r
    while [ -n "$rest" ]; do
      r="${rest%%,*}"; rest="${rest#*,}"
      [ -z "$r" ] && continue
      echo "  - $r"
    done
  fi
  echo
  echo "── 摘要（注入；原文仍以规则文件为准）──"
  print_summaries "$RULES_OUT"
  echo
  echo "── 下一步 ──"
  echo "按以上摘要写代码。摘要不够再打开原文。不要加载未匹配的规则全文。"
  echo "不要要求用户先跑 agency 命令；本输出可直接当上下文。"
}

# ---------- 生成写入项目的路由段 ----------

md_table_from_tsv() {
  echo "| 信号 | 加载规则 | Agent | 风险 |"
  echo "| --- | --- | --- | --- |"
  local line type id pattern agents rules wf risk st hint
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in \#*|"") continue;; esac
    IFS='|' read -r type id pattern agents rules wf risk st hint <<EOF
$line
EOF
    [ "$type" = always ] && continue
    rules_disp="$rules"; agents_disp="$agents"
    [ -n "$rules_disp" ] && rules_disp="\`$rules_disp\`" || rules_disp="—"
    [ -n "$agents_disp" ] && agents_disp="\`$agents_disp\`" || agents_disp="—"
    echo "| \`$pattern\` | $rules_disp | $agents_disp | ${risk:--} |"
  done < "$TABLE"
}

summaries_for_stacks() {
  local stacks="$1"
  local line type id pattern agents rules wf risk st hint rest item
  local emitted=""
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in \#*|"") continue;; esac
    IFS='|' read -r type id pattern agents rules wf risk st hint <<EOF
$line
EOF
    if [ "$type" != always ]; then
      if [ "$st" != "any" ] && [ -n "$stacks" ] && ! csv_has "$stacks" "$st" && ! csv_has "$stacks" any; then
        continue
      fi
    fi
    rest="${rules},"
    while [ -n "$rest" ]; do
      item="${rest%%,*}"; rest="${rest#*,}"
      item="$(printf '%s' "$item" | sed 's/^ *//;s/ *$//')"
      [ -z "$item" ] && continue
      csv_has "$emitted" "$item" && continue
      emitted="$(add_csv "$emitted" "$item")"
      echo
      echo "### $item"
      local sum=""
      sum="$(extract_summary "$AGENCY_ROOT/$item" 2>/dev/null || true)"
      if [ -n "$sum" ]; then
        printf '%s\n' "$sum"
      else
        echo "- $hint"
      fi
      echo
      echo "原文路径：\`$item\`（项目内通常是 \`.ai/agency/$item\`）"
    done
  done < "$TABLE"
}

render_pin_markdown() {
  cat <<EOF
$PIN_BEGIN
## 写代码前（钉死，勿删）

1. 先按「规范路由」匹配再动手，不必先跑 \`agency\` 命令。
2. 只加载命中规则的摘要；**写代码时**命中的语言/领域规则必须再打开文内「原文路径」（摘要会丢掉约束）。探测任务 \`opened=none\`。
3. 回复第一行：
   \`agency-route: matched=<id,id> risk=L2 rules=rules/java.md opened=rules/java.md source=agents.md\`
4. 常驻红线：先读再改；最小改动；密钥不进源码；SQL 参数化。
5. 汇报：L1 三行；L2 短汇报；L3 完整表。业务仓无规则缺口则不写 feedback。
6. 强制靠 \`agency check\`（只卡增量）。存量用 \`agency check --all\` 做台账，不进 hook。
$PIN_END
EOF
}

render_router_markdown() {
  local stacks="$1"
  local stack_note="检测技术栈：${stacks:-未检测，保留全表}"
  cat <<EOF
$ROUTER_BEGIN
## 规范路由（提示词自动生效，不必先跑命令）

收到写代码 / 改接口 / 改页面 / 改 SQL / 修 bug 的任务时，**先按本段路由，再动手**。
不要等用户输入 \`agency route\` 或 \`agency use\`。

$stack_note

### 怎么匹配

1. 对照下面的信号表：任务关键词或将要改的文件。
2. **只加载命中行的规则摘要**（本段已内嵌裁剪后的摘要）。
3. 摘要不够再打开原文；不要把未命中的语言规范整篇塞进上下文。
4. 每次都生效：\`rules/global.md\` + \`rules/minimalism.md\` + \`rules/security.md\`。
5. 写代码回复的第一行必须是路由回执（给人核对有没有触发、有没有打开原文）：
   \`agency-route: matched=<id,id> risk=L2 rules=rules/java.md opened=rules/java.md source=agents.md\`

### 信号表

EOF
  md_table_from_tsv
  cat <<EOF

### 本项目应注入的摘要

EOF
  summaries_for_stacks "$stacks"
  cat <<EOF

### 仍不要做的事

- 不要为了「走完流程」加载全部 Agent Prompt。
- 不要把 \`.ai/agency/\` 整库读进上下文。
- 红线靠本摘要降低违规概率；真正强制是 \`agency check\`（git hook / CI），只卡增量、不卡存量。
- 不要省略路由回执；没有 \`agency-route:\` 第一行，人无法核对本次是否触发。
- 写代码时 \`opened=\` 必须是本会话真实打开过的规则原文；编造视为假回执。探测可 \`opened=none\`。
$ROUTER_END
EOF
}

render_cursor_mdc() {
  local stacks="$1"
  cat <<EOF
---
description: Agency 规范路由。写代码前按任务/文件匹配规则摘要，摘要不够再打开原文。提示词自动生效，用户不必先跑命令。
alwaysApply: true
---

EOF
  render_pin_markdown | grep -v 'agency-pin:'
  echo
  render_router_markdown "$stacks" | grep -v 'agency-router:'
}

upsert_marked_section() {
  local file="$1"
  local snippet_file="$2"
  local begin="${3:-agency-router:begin}"
  local end="${4:-agency-router:end}"
  if [ ! -f "$file" ]; then
    cp "$snippet_file" "$file"
    return 0
  fi
  if grep -q "$begin" "$file"; then
    local tmp; tmp="$(mktemp)"
    awk -v snippet="$snippet_file" -v begin="$begin" -v end="$end" '
      index($0, begin) {
        skip=1
        while ((getline line < snippet) > 0) print line
        close(snippet)
        next
      }
      index($0, end) { skip=0; next }
      skip { next }
      { print }
    ' "$file" > "$tmp"
    mv "$tmp" "$file"
  else
    echo >> "$file"
    cat "$snippet_file" >> "$file"
  fi
}

upsert_pin_at_head() {
  local file="$1"
  local snippet_file="$2"
  if [ ! -f "$file" ]; then
    cp "$snippet_file" "$file"
    return 0
  fi
  if grep -q 'agency-pin:begin' "$file"; then
    upsert_marked_section "$file" "$snippet_file" "agency-pin:begin" "agency-pin:end"
    return 0
  fi
  local tmp; tmp="$(mktemp)"
  awk -v snippet="$snippet_file" '
    /^# / && !done {
      print
      print ""
      while ((getline line < snippet) > 0) print line
      close(snippet)
      print ""
      done=1
      next
    }
    { print }
    END {
      if (!done) {
        while ((getline line < snippet) > 0) print line
        close(snippet)
      }
    }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

cmd_print() {
  local dir="$1" task="$2" files="$3" stack_override="$4"
  [ -f "$TABLE" ] || { echo "缺少路由表: $TABLE" >&2; exit 1; }
  local stack="$stack_override"
  [ -z "$stack" ] && stack="$(detect_stack "$dir")"
  local tmp; tmp="$(mktemp)"
  match_routes "$task" "$files" "$stack" "$tmp"
  print_route_report "$dir" "$task" "$files" "$stack" "$tmp"
  rm -f "$tmp"
}

cmd_install() {
  local dir="$1" stack_override="$2"
  [ -d "$dir" ] || { echo "项目目录不存在: $dir" >&2; exit 1; }
  if [ "$dir" = "$AGENCY_ROOT" ]; then
    echo "规范库自身请用: agency route --refresh-docs" >&2
    exit 1
  fi
  [ -f "$TABLE" ] || { echo "缺少路由表: $TABLE" >&2; exit 1; }
  local stack="$stack_override"
  [ -z "$stack" ] && stack="$(detect_stack "$dir")"
  # 未检测出任何栈时，install 仍写入全表摘要，保证「所有项目都能用上」
  local stacks_for_summary="$stack"
  [ -z "$stacks_for_summary" ] && stacks_for_summary="java,vue,react,python,sqlserver,ai,healthcare,any"

  local snippet pin; snippet="$(mktemp)"; pin="$(mktemp)"
  render_router_markdown "$stacks_for_summary" > "$snippet"
  render_pin_markdown > "$pin"

  if [ -f "$dir/AGENTS.md" ]; then
    upsert_pin_at_head "$dir/AGENTS.md" "$pin"
    upsert_marked_section "$dir/AGENTS.md" "$snippet"
    echo "✓ 更新 $dir/AGENTS.md 写代码前钉死段 + 规范路由段"
  else
    cp "$AGENCY_ROOT/templates/project-AGENTS.md" "$dir/AGENTS.md"
    upsert_pin_at_head "$dir/AGENTS.md" "$pin"
    upsert_marked_section "$dir/AGENTS.md" "$snippet"
    echo "✓ 创建 $dir/AGENTS.md（含钉死段与规范路由段）"
  fi

  mkdir -p "$dir/.cursor/rules"
  render_cursor_mdc "$stacks_for_summary" > "$dir/.cursor/rules/agency-router.mdc"
  echo "✓ 写入 $dir/.cursor/rules/agency-router.mdc"

  mkdir -p "$dir/.agents/skills"
  rm -rf "$dir/.agents/skills/agency-route"
  cp -R "$AGENCY_ROOT/skills/agency-route" "$dir/.agents/skills/agency-route"
  echo "✓ 写入 $dir/.agents/skills/agency-route/"

  rm -f "$snippet" "$pin"
  echo "完成：提示词自动路由已写入项目（可提交 AGENTS.md / .cursor/rules / .agents/skills）"
  echo "技术栈: ${stack:-未检测，已写入全量摘要}"
}

cmd_refresh_docs() {
  local stacks="java,vue,react,python,sqlserver,ai,healthcare,any"
  local snippet pin; snippet="$(mktemp)"; pin="$(mktemp)"
  render_router_markdown "$stacks" > "$snippet"
  render_pin_markdown > "$pin"

  upsert_pin_at_head "$AGENCY_ROOT/AGENTS.md" "$pin"
  upsert_marked_section "$AGENCY_ROOT/AGENTS.md" "$snippet"
  echo "✓ 刷新 AGENTS.md 钉死段 + 规范路由段"

  upsert_pin_at_head "$AGENCY_ROOT/templates/project-AGENTS.md" "$pin"
  upsert_marked_section "$AGENCY_ROOT/templates/project-AGENTS.md" "$snippet"
  echo "✓ 刷新 templates/project-AGENTS.md 钉死段 + 规范路由段"

  mkdir -p "$AGENCY_ROOT/templates/cursor-rules"
  render_cursor_mdc "$stacks" > "$AGENCY_ROOT/templates/cursor-rules/agency-router.mdc"
  echo "✓ 刷新 templates/cursor-rules/agency-router.mdc"

  cp "$snippet" "$AGENCY_ROOT/templates/project-router-section.md"
  echo "✓ 刷新 templates/project-router-section.md"

  rm -f "$snippet" "$pin"
}

# ---------- 参数 ----------

MODE="print"
DIR="$(pwd)"
TASK=""
FILES=""
STACK=""
INSTALL_DIR=""

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0;;
    --task) TASK="${2:-}"; shift 2;;
    --files) FILES="${2:-}"; shift 2;;
    --dir) DIR="${2:-}"; shift 2;;
    --stack) STACK="${2:-}"; shift 2;;
    --install)
      MODE="install"
      if [ -n "${2:-}" ] && [ "${2#--}" = "$2" ]; then
        INSTALL_DIR="$2"; shift 2
      else
        shift
      fi
      ;;
    --refresh-docs) MODE="refresh"; shift;;
    *)
      echo "未知参数: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

case "$MODE" in
  print)
    DIR="$(cd "$DIR" 2>/dev/null && pwd)" || { echo "目录不存在: $DIR" >&2; exit 1; }
    cmd_print "$DIR" "$TASK" "$FILES" "$STACK"
    ;;
  install)
    [ -z "$INSTALL_DIR" ] && INSTALL_DIR="$DIR"
    INSTALL_DIR="$(cd "$INSTALL_DIR" 2>/dev/null && pwd)" || { echo "目录不存在: $INSTALL_DIR" >&2; exit 1; }
    cmd_install "$INSTALL_DIR" "$STACK"
    ;;
  refresh)
    cmd_refresh_docs
    ;;
esac
