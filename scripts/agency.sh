#!/usr/bin/env bash
# ============================================================
# agency — AI Development Agency 日常使用 CLI（零依赖）
#
# 用法：
#   agency help                    帮助
#   agency status [dir]            检查项目接入状态（doctor）
#   agency init [dir]              初始化项目接入（软链接 + AGENTS.md）
#   agency list [agents|rules|workflows|context]   列出分类内容
#   agency use <agent> [--raw]     组装并打印某 Agent 的完整使用块（可选；提示词会自动路由）
#   agency route [--task|--files|--dir]   查看本次任务命中的规范摘要（可选检查器）
#   agency route --install [dir]   把自动路由段写入业务项目（可提交）
#   agency route --refresh-docs    按路由表刷新本仓库 AGENTS.md / 模板
#   agency search <关键词>         在规范库中搜索
#   agency require [--title] [dir] 创建需求单（人提需求用，产物在项目 .ai/requirements/）
#   agency task [--title] [dir]    创建任务单（AI 执行证据，产物在项目 .ai/tasks/）
#   agency audit [dir]             交叉核对任务单，验证 AI 是否真实按规范执行
#   agency debt [dir]              收割 agency: 注释为债务台账（简化留痕）
#   agency feedback ...            记录规则使用反馈（自进化采集层）
#   agency propose ...             创建规则/规范改进提案（自进化提案层）
#   agency review                  生成本轮评审简报（自进化评审层）
#   agency validate                校验规范库完整性（自进化守门）
#   agency changelog               查看版本变更记录
#   agency version                 查看当前规范版本
#   agency update                  拉取最新规范并刷新项目链接
# ============================================================
set -euo pipefail

# 解析脚本真实路径（支持通过符号链接从 PATH 调用，如 ~/.local/bin/agency）
SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
AGENCY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

usage() {
  sed -n '3,26p' "$0" | sed 's/^# \{0,1\}//'
}

version_of() {
  # 从 AGENTS.md 提取版本号
  grep -m1 -oE 'v[0-9]+\.[0-9]+(\.[0-9]+)?' "$AGENCY_ROOT/AGENTS.md" | head -1 || echo "unknown"
}

cmd_help() { usage; }

cmd_version() {
  echo "AI Development Agency $(version_of)  ($AGENCY_ROOT)"
}

cmd_status() {
  "$SCRIPT_DIR/doctor.sh" "${1:-$(pwd)}"
}

cmd_init() {
  "$SCRIPT_DIR/init-project.sh" "${1:-$(pwd)}"
}

cmd_list() {
  local cat="${1:-all}"
  local dir
  case "$cat" in
    agents)    dir="agents";;
    rules)     dir="rules";;
    workflows) dir="workflows";;
    context)   dir="context";;
    contracts) dir="contracts";;
    all)       echo "== agents =="; (cd "$AGENCY_ROOT" && find agents -name '*.md' | sort);
               echo "== rules ==";  (cd "$AGENCY_ROOT" && find rules -name '*.md' | sort);
               echo "== workflows =="; (cd "$AGENCY_ROOT" && find workflows -name '*.md' | sort);
               echo "== context =="; (cd "$AGENCY_ROOT" && find context -name '*.md' | sort); return 0;;
    *) echo "未知分类: $cat（可用: agents|rules|workflows|context|contracts|all）" >&2; return 1;;
  esac
  (cd "$AGENCY_ROOT" && find "$dir" -name '*.md' | sort)
}

# 解析 agent 名称 → 文件路径（支持 java-developer / agents/backend/java-developer.md）
resolve_agent() {
  local name="$1"
  local file
  if [[ "$name" == *.md && -f "$AGENCY_ROOT/$name" ]]; then
    echo "$AGENCY_ROOT/$name"; return 0
  fi
  file="$(cd "$AGENCY_ROOT" && find agents -name "$name.md" 2>/dev/null | head -1)"
  [ -n "$file" ] && { echo "$AGENCY_ROOT/$file"; return 0; }
  file="$(cd "$AGENCY_ROOT" && find agents -name "*${name}*.md" 2>/dev/null | head -1)"
  [ -n "$file" ] && { echo "$AGENCY_ROOT/$file"; return 0; }
  return 1
}

# 从 agent 正文提取“必读文件”引用（backtick 包裹、可解析为规范库文件）
extract_reads() {
  local file="$1"
  grep -oE '\`[^\`]+\`' "$file" \
    | tr -d '`' \
    | while read -r ref; do
        case "$ref" in
          AGENTS.md) echo "AGENTS.md";;
          agents/*|rules/*|context/*|workflows/*|contracts/*|artifacts/*|validation/*|templates/*)
            if [ -f "$AGENCY_ROOT/$ref" ]; then echo "$ref"; else echo "✗ 缺失: $ref" >&2; fi;;
        esac
      done
}

cmd_use() {
  local name="${1:-}"; [ -n "$name" ] || { echo "用法: agency use <agent>" >&2; return 1; }
  local raw="${2:-}"
  local file
  file="$(resolve_agent "$name")" || { echo "找不到 Agent: $name（用 agency list agents 查看）" >&2; return 1; }
  local rel="${file#"$AGENCY_ROOT"/}"
  echo "════════════════════════════════════════════"
  echo "Agent: $rel"
  echo "════════════════════════════════════════════"
  cat "$file"
  if [ "$raw" != "--raw" ]; then
    echo
    echo "──── 必读文件（自动解析，建议全部加载）────"
    extract_reads "$file" | sort -u | sed 's/^/  /'
    echo
    echo "──── 建议 Workflow（按任务类型选择，见 workflows/）────"
    echo "  普通功能: workflows/feature-development.md"
    echo "  Bug 修复: workflows/bug-fixing.md"
    echo "  数据库变更: workflows/database-change.md"
  fi
}

cmd_search() {
  local kw="${1:-}"; [ -n "$kw" ] || { echo "用法: agency search <关键词>" >&2; return 1; }
  (cd "$AGENCY_ROOT" && grep -rn --include='*.md' -i "$kw" agents rules workflows context contracts artifacts validation 2>/dev/null || echo "无匹配")
}

cmd_feedback() { "$SCRIPT_DIR/feedback.sh" "$@"; }
cmd_propose()  { "$SCRIPT_DIR/propose.sh" "$@"; }
cmd_require()  { "$SCRIPT_DIR/requirement.sh" "$@"; }
cmd_task()     { "$SCRIPT_DIR/task.sh" "$@"; }
cmd_audit()    { "$SCRIPT_DIR/audit.sh" "$@"; }
cmd_debt()     { "$SCRIPT_DIR/debt.sh" "${1:-}"; }
cmd_review()   { "$SCRIPT_DIR/review.sh" "$@"; }
cmd_validate() { "$SCRIPT_DIR/validate.sh"; }
cmd_route()    { "$SCRIPT_DIR/route.sh" "$@"; }

cmd_changelog() {
  local f="$AGENCY_ROOT/CHANGELOG.md"
  [ -f "$f" ] && head -60 "$f" || echo "暂无 CHANGELOG.md"
}

cmd_update() {
  echo "==> 拉取中央 Agency 最新规范"
  git -C "$AGENCY_ROOT" pull --ff-only
  echo "==> 刷新当前项目接入"
  "$SCRIPT_DIR/init-project.sh" "$(pwd)"
}

cmd="${1:-help}"; shift || true
case "$cmd" in
  help|-h|--help)        cmd_help;;
  version|-v)            cmd_version;;
  status|check|doctor)   cmd_status "${1:-}";;
  init)                  cmd_init "${1:-}";;
  list|ls)               cmd_list "${1:-}";;
  use)                   cmd_use "${1:-}" "${2:-}";;
  route)                 cmd_route "$@";;
  search|grep)           cmd_search "${1:-}";;
  feedback)              cmd_feedback "$@";;
  propose)               cmd_propose "$@";;
  require)               cmd_require "$@";;
  task)                  cmd_task "$@";;
  audit)                 cmd_audit "${1:-}";;
  debt)                  cmd_debt "${1:-}";;
  review)                cmd_review;;
  validate)              cmd_validate;;
  changelog)             cmd_changelog;;
  update)                cmd_update;;
  *) echo "未知命令: $cmd" >&2; usage >&2; exit 1;;
esac
