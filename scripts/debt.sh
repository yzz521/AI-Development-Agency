#!/usr/bin/env bash
# ============================================================
# agency debt — 收割 agency: 注释为债务台账（简化留痕）
#
# 用法：
#   agency debt [dir]       扫描目录（默认规范库根）
#
# 识别 rules/minimalism.md 约定的债务注释（代码注释）：
#   # agency: <上限>, <升级路径>
# 示例：
#   # agency: 全局锁，吞吐成为瓶颈时改按账号分锁
#   # agency: O(n²) 扫描，规则库超 1 万条时改索引方案
#
# 输出台账：文件:行号 | 上限 | 升级路径 | 状态
#   - 逗号后为空（无升级路径）→ 状态 no-trigger（防腐烂，防“以后再说”变成“永远不做”）
# 退出码：存在 no-trigger 债务时返回 1，否则 0。
# ============================================================
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENCY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET="${1:-$AGENCY_ROOT}"

total=0
no_trigger=0
no_trigger_list=()

while IFS= read -r line; do
  [ -n "$line" ] || continue
  # grep -rn 输出: 路径:行号:行内容
  file="${line%%:*}"; rest="${line#*:}"
  lineno="${rest%%:*}"; text="${rest#*:}"
  # 只统计代码文件（债务注释认代码，不认 Markdown 正文）
  case "$file" in
    *.sh|*.bash|*.zsh|*.js|*.mjs|*.cjs|*.ts|*.tsx|*.jsx|*.java|*.kt|*.py|*.go|*.rs|*.c|*.h|*.cpp|*.cc|*.hpp|*.cs|*.rb|*.php|*.sql|*.vue|*.css|*.scss|*.less|*.html|*.xml|*.yml|*.yaml|*.json|*.properties) ;;
    *) continue;;
  esac
  # 跳过反引号包裹的引用（如文档里写的 `agency:`）
  before="${text%%agency:*}"
  case "$before" in
    *'`'*) continue;;
  esac
  # 只认注释形式：agency: 前必须紧跟注释标记（# // /* * -- ; <!--）
  before="${before%"${before##*[![:space:]]}"}"
  case "$before" in
    *'#'|*'//'|*'/*'|*'*'|*'--'|*';'|*'<!--') ;;
    *) continue;;
  esac
  ann="${text#*agency:}"
  # 去掉前后空白
  ann="${ann#"${ann%%[![:space:]]*}"}"
  ann="${ann%"${ann##*[![:space:]]}"}"
  # 按第一个分隔符（，或 ,）拆出上限与升级路径
  if [[ "$ann" == *，* ]]; then
    upper="${ann%，*}"; path="${ann#*，}"
  elif [[ "$ann" == *,* ]]; then
    upper="${ann%,*}"; path="${ann#*,}"
  else
    upper="$ann"; path=""
  fi
  upper="${upper#"${upper%%[![:space:]]*}"}"; upper="${upper%"${upper##*[![:space:]]}"}"
  path="${path#"${path%%[![:space:]]*}"}"; path="${path%"${path##*[![:space:]]}"}"
  if [ -n "$path" ]; then
    status="ok"
  else
    status="no-trigger"
    no_trigger=$((no_trigger+1))
    no_trigger_list+=("$file:$lineno")
  fi
  total=$((total+1))
  printf '%s:%s | %s | %s | %s\n' "$file" "$lineno" "$upper" "$path" "$status"
done < <(grep -rn --exclude-dir=.git --exclude=debt.sh 'agency:' "$TARGET" 2>/dev/null || true)

echo
echo "债务台账：共 $total 条（含升级路径 $((total-no_trigger))，no-trigger $no_trigger）"
if [ "$no_trigger" -gt 0 ]; then
  echo "防腐烂提醒：以下债务没有升级路径（“以后再说”会变成“永远不做”）："
  for item in "${no_trigger_list[@]}"; do echo "  - $item"; done
  exit 1
fi
exit 0
