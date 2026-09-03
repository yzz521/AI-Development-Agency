#!/usr/bin/env bash
# ============================================================
# agency check — 增量规范门禁（只卡 diff 新增行）
#
# 用法：
#   agency check [dir]
#   agency check --staged [dir]
#   agency check --base <ref> [dir]
#   agency check --all [dir]
#   agency check --install [dir]
#   agency check --list [dir]
#   agency check --enable <id> --disable <id>
#
# 设计：
#   注入 ≠ 遵守。本命令给 git hook / CI 用，默认只看新增行。
#   不要拿 --all 当提交门禁。
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 源码树：scripts/check.sh → ../checks/catalog.tsv
# 业务仓副本：.agency-check/check.sh → ./catalog.tsv
if [ -f "$SCRIPT_DIR/catalog.tsv" ]; then
  CATALOG="$SCRIPT_DIR/catalog.tsv"
  AGENCY_ROOT="${AGENCY_ROOT:-}"
  if [ -z "$AGENCY_ROOT" ] && [ -f "$SCRIPT_DIR/../AGENTS.md" ]; then
    AGENCY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
  fi
elif [ -f "$SCRIPT_DIR/../checks/catalog.tsv" ]; then
  CATALOG="$SCRIPT_DIR/../checks/catalog.tsv"
  AGENCY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
else
  echo "找不到 checks/catalog.tsv" >&2
  exit 2
fi

usage() { sed -n '3,20p' "$0" | sed 's/^# \{0,1\}//'; }

# ---------- bash 3.2 工具 ----------

trim() { printf '%s' "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'; }

csv_has() {
  local csv="$1" item="$2" x rest
  [ -z "$csv" ] && return 1
  rest="$csv,"
  while [ -n "$rest" ]; do
    x="${rest%%,*}"; rest="${rest#*,}"
    x="$(trim "$x")"
    [ "$x" = "$item" ] && return 0
  done
  return 1
}

add_csv() {
  local csv="$1" item="$2"
  csv_has "$csv" "$item" && { printf '%s' "$csv"; return; }
  [ -z "$csv" ] && { printf '%s' "$item"; return; }
  printf '%s,%s' "$csv" "$item"
}

file_matches_glob() {
  local path="$1" glob="$2"
  local base="${path##*/}"
  glob="$(trim "$glob")"
  [ -z "$glob" ] && return 1
  case "$glob" in
    */*)
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

file_matches_any_glob() {
  local path="$1" patterns="$2" rest p
  rest="$patterns,"
  while [ -n "$rest" ]; do
    p="${rest%%,*}"; rest="${rest#*,}"
    p="$(trim "$p")"
    [ -z "$p" ] && continue
    file_matches_glob "$path" "$p" && return 0
  done
  return 1
}

lstrip_ws() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  printf '%s' "$s"
}

is_comment_or_import() {
  local s
  s="$(lstrip_ws "$1")"
  case "$s" in
    "") return 0;;
    import[[:space:]]*|package[[:space:]]*) return 0;;
    //*|\#*) return 0;;
    --*) return 0;;
    /\**|\**|\*/) return 0;;
    \<!--*) return 0;;
  esac
  return 1
}

skip_path() {
  local path="$1" base="${1##*/}"
  case "$path" in
    .git/*|*/.git/*) return 0;;
    node_modules/*|*/node_modules/*) return 0;;
    target/*|*/target/*) return 0;;
    dist/*|*/dist/*) return 0;;
    build/*|*/build/*) return 0;;
    .agency-check/*|*/.agency-check/*) return 0;;
    docs/*|*/docs/*) return 0;;
  esac
  case "$base" in
    *.md) return 0;;
    *example*|*sample*|*template*) return 0;;
    *.jar|*.class|*.png|*.jpg|*.jpeg|*.gif|*.webp|*.pdf|*.zip|*.gz|*.woff|*.woff2|*.ico)
      return 0;;
  esac
  return 1
}

# ---------- catalog / conf ----------

load_conf() {
  local file="$1"
  CONF_BASE=""
  CONF_ON=""
  CONF_OFF=""
  [ -f "$file" ] || return 0
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in \#*|"") continue;; esac
    line="$(trim "$line")"
    case "$line" in
      base=*) CONF_BASE="${line#base=}";;
      *=on)
        CONF_ON="$(add_csv "$CONF_ON" "${line%=on}")";;
      *=off)
        CONF_OFF="$(add_csv "$CONF_OFF" "${line%=off}")";;
    esac
  done < "$file"
}

catalog_field() {
  # id → print one TSV row
  local want="$1" id default severity globs engine rule message
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in \#*|"") continue;; esac
    IFS='|' read -r id default severity globs engine rule message <<EOF
$line
EOF
    [ "$id" = "$want" ] && { printf '%s\n' "$line"; return 0; }
  done < "$CATALOG"
  return 1
}

check_enabled() {
  local id="$1" default="$2"
  csv_has "$CLI_DISABLE" "$id" && return 1
  csv_has "$CLI_ENABLE" "$id" && return 0
  csv_has "$CONF_OFF" "$id" && return 1
  csv_has "$CONF_ON" "$id" && return 0
  [ "$default" = "on" ]
}

list_checks() {
  local id default severity globs engine rule message state
  printf '%-24s %-8s %-8s %s\n' "ID" "STATE" "SEV" "GLOBS"
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in \#*|"") continue;; esac
    IFS='|' read -r id default severity globs engine rule message <<EOF
$line
EOF
    if check_enabled "$id" "$default"; then state="on"; else state="off"; fi
    printf '%-24s %-8s %-8s %s\n' "$id" "$state" "$severity" "$globs"
  done < "$CATALOG"
}

# ---------- 引擎 ----------

hit_java_map() {
  printf '%s' "$1" | grep -qE '(Map|MutableMap|HashMap|LinkedHashMap|ConcurrentHashMap|TreeMap)[[:space:]]*<[[:space:]]*String[[:space:]]*,[[:space:]]*(Object|Any)[[:space:]]*\??[[:space:]]*>'
}

hit_select_star() {
  printf '%s' "$1" | grep -qiE 'select[[:space:]]+\*'
}

hit_sql_limit() {
  printf '%s' "$1" | grep -qiE 'limit[[:space:]]+([0-9?]|#\{|\$\{)'
}

hit_sql_backtick() {
  printf '%s' "$1" | grep -qE '`[A-Za-z_]'
}

hit_pathvariable() {
  printf '%s' "$1" | grep -q '@PathVariable'
}

hit_fqcn() {
  printf '%s' "$1" | grep -qE '([^[:alnum:]_.]|^)java\.(lang|util|io|sql|time|math|net|nio|text|beans|awt)\.[A-Z][A-Za-z0-9_]+'
}

hit_requestbody_valid() {
  printf '%s' "$1" | grep -q '@RequestBody' || return 1
  printf '%s' "$1" | grep -qE '@Valid|@Validated' && return 1
  return 0
}

hit_sensitive_log() {
  printf '%s' "$1" | grep -qiE 'log\.(info|debug|warn|error|trace|printf)' || return 1
  printf '%s' "$1" | grep -qiE 'idcard|id_card|身份证|patientname|patient_name|病历号|病案号|住院号|手机号|phone_number'
}

secret_key_line() {
  printf '%s' "$1" | grep -qiE '(^|[^A-Za-z0-9_])(password|secret|api[-_]?key|access[-_]?key|private[-_]?key|client[-_]?secret|aws[-_]?secret[-_]?access[-_]?key)[[:space:]]*[:=]'
}

secret_key_is_name() {
  local s="$1"
  printf '%s' "$s" | grep -qiE 'secret(name|ref|keyref)|password(file|path|encoder|hash)|secretsmanager'
}

secret_value_ok() {
  local v="$1"
  v="$(trim "$v")"
  v="${v#\'}"; v="${v%\'}"
  v="${v#\"}"; v="${v%\"}"
  v="$(trim "$v")"
  [ -z "$v" ] && return 0
  case "$v" in
    null|NULL|nil|None|undefined|~) return 0;;
    '<'*'>') return 0;;
    '{{'*'}}') return 0;;
    ENC\(*\)) return 0;;
    vault:*|ssm:*|aws:kms:*|arn:aws:*) return 0;;
  esac
  # ${FOO} ${FOO:} ${FOO:-}
  printf '%s' "$v" | grep -qE '^\$\{[A-Za-z_][A-Za-z0-9_.]*(:-?)?\}$' && return 0
  return 1
}

hit_secret() {
  local line="$1" val
  secret_key_line "$line" || return 1
  secret_key_is_name "$line" && return 1
  val="$(printf '%s' "$line" | sed -E 's/^[^=:]*[:=][[:space:]]*//; s/[[:space:]]+#.*$//; s/[[:space:]]*$//')"
  if secret_value_ok "$val"; then
    return 1
  fi
  return 0
}

run_engine() {
  local engine="$1" text="$2"
  case "$engine" in
    java-map-object) hit_java_map "$text" ;;
    sql-select-star) hit_select_star "$text" ;;
    secret-hardcoded) hit_secret "$text" ;;
    java-pathvariable) hit_pathvariable "$text" ;;
    sql-limit) hit_sql_limit "$text" ;;
    sql-backtick) hit_sql_backtick "$text" ;;
    java-fqcn) hit_fqcn "$text" ;;
    java-requestbody-valid) hit_requestbody_valid "$text" ;;
    java-sensitive-log) hit_sensitive_log "$text" ;;
    *) echo "未知 engine: $engine" >&2; return 1 ;;
  esac
}

# ---------- 收集新增行 ----------

# 输出：path<TAB>lineno<TAB>text
emit_file_lines() {
  local path="$1" file="$2"
  local n=0 line
  [ -f "$file" ] || return 0
  [ -s "$file" ] || return 0
  while IFS= read -r line || [ -n "$line" ]; do
    n=$((n+1))
    line="${line%$'\r'}"
    printf '%s\t%s\t%s\n' "$path" "$n" "$line"
  done < "$file"
}

parse_unified_diff() {
  local file="" new_line=0 line t path
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%$'\r'}"
    case "$line" in
      diff\ --git\ *)
        file=""
        ;;
      +++\ /dev/null)
        file=""
        ;;
      +++\ *)
        path="${line#+++ }"
        path="${path#b/}"
        # 去掉可能的 tab 后旧时间戳
        path="${path%%$'\t'*}"
        case "$path" in
          /dev/null) file="";;
          *) file="$path";;
        esac
        ;;
      @@\ *)
        t="${line#@@ }"
        t="${t#*+}"
        t="${t%% *}"
        new_line="${t%%,*}"
        [ -n "$new_line" ] || new_line=0
        ;;
      +*)
        [ -n "$file" ] || continue
        printf '%s\t%s\t%s\n' "$file" "$new_line" "${line#+}"
        new_line=$((new_line+1))
        ;;
      -*)
        ;;
      \ *)
        [ -n "$file" ] || continue
        new_line=$((new_line+1))
        ;;
    esac
  done
}

git_in() {
  git -C "$GIT_ROOT" "$@"
}

collect_added() {
  local out="$1"
  : > "$out"
  case "$MODE" in
    all)
      if [ -n "$GIT_ROOT" ]; then
        git_in ls-files -z | while IFS= read -r -d '' rel; do
          skip_path "$rel" && continue
          emit_file_lines "$rel" "$GIT_ROOT/$rel"
        done >> "$out"
      else
        (cd "$PROJECT_DIR" && find . -type f ! -path './.git/*' | sed 's|^\./||') | while IFS= read -r rel; do
          skip_path "$rel" && continue
          emit_file_lines "$rel" "$PROJECT_DIR/$rel"
        done >> "$out"
      fi
      ;;
    staged)
      git_in diff --cached -U0 --diff-filter=ACMR --src-prefix=a/ --dst-prefix=b/ | parse_unified_diff >> "$out"
      ;;
    base)
      git_in diff -U0 --diff-filter=ACMR --src-prefix=a/ --dst-prefix=b/ "$BASE"...HEAD | parse_unified_diff >> "$out"
      ;;
    work)
      git_in diff -U0 --diff-filter=ACMR --src-prefix=a/ --dst-prefix=b/ HEAD | parse_unified_diff >> "$out"
      git_in ls-files --others --exclude-standard -z | while IFS= read -r -d '' rel; do
        skip_path "$rel" && continue
        emit_file_lines "$rel" "$GIT_ROOT/$rel"
      done >> "$out"
      ;;
  esac
}

# ---------- 扫描 ----------

scan() {
  local lines_file="$1"
  local id default severity globs engine rule message
  local path lineno text
  FAIL_N=0
  HIT_IDS=""
  ENABLED_IDS=""

  while IFS= read -r crow || [ -n "$crow" ]; do
    case "$crow" in \#*|"") continue;; esac
    IFS='|' read -r id default severity globs engine rule message <<EOF
$crow
EOF
    check_enabled "$id" "$default" || continue
    ENABLED_IDS="$(add_csv "$ENABLED_IDS" "$id")"
    while IFS=$'\t' read -r path lineno text || [ -n "$path" ]; do
      [ -n "$path" ] || continue
      skip_path "$path" && continue
      file_matches_any_glob "$path" "$globs" || continue
      is_comment_or_import "$text" && continue
      if run_engine "$engine" "$text"; then
        FAIL_N=$((FAIL_N+1))
        HIT_IDS="$(add_csv "$HIT_IDS" "$id")"
        printf 'FAIL %s  %s:%s  %s\n' "$id" "$path" "$lineno" "$message"
        printf '     %s\n' "$(lstrip_ws "$text" | cut -c1-200)"
      fi
    done < "$lines_file"
  done < "$CATALOG"
}

# ---------- install ----------

cmd_install() {
  local dir="$1"
  [ -d "$dir" ] || { echo "项目目录不存在: $dir" >&2; exit 2; }
  dir="$(cd "$dir" && pwd)"
  if [ -n "$AGENCY_ROOT" ] && [ "$dir" = "$AGENCY_ROOT" ]; then
    echo "规范库自身请用 scripts/validate.sh，不要 agency check --install 自己。" >&2
    exit 2
  fi
  [ -n "$AGENCY_ROOT" ] || { echo "--install 需要完整规范库（templates/）。请用 agency check --install，不要用业务仓里的 .agency-check/check.sh。" >&2; exit 2; }

  mkdir -p "$dir/.agency-check" "$dir/.githooks" "$dir/.github/workflows" "$dir/.agents/skills"

  cp "$AGENCY_ROOT/scripts/check.sh" "$dir/.agency-check/check.sh"
  cp "$AGENCY_ROOT/checks/catalog.tsv" "$dir/.agency-check/catalog.tsv"
  chmod +x "$dir/.agency-check/check.sh"
  echo "✓ 写入 $dir/.agency-check/（可提交，CI/hook 不依赖 .ai/agency）"

  cp "$AGENCY_ROOT/templates/githooks/pre-commit" "$dir/.githooks/pre-commit"
  chmod +x "$dir/.githooks/pre-commit"
  echo "✓ 写入 $dir/.githooks/pre-commit"

  if [ -f "$dir/agency-check.conf" ] && [ "$FORCE" != "1" ]; then
    echo "✓ 保留已有 $dir/agency-check.conf"
  else
    cp "$AGENCY_ROOT/templates/agency-check.conf" "$dir/agency-check.conf"
    echo "✓ 写入 $dir/agency-check.conf"
  fi

  if [ -f "$dir/.github/workflows/agency-check.yml" ] && [ "$FORCE" != "1" ]; then
    echo "✓ 保留已有 $dir/.github/workflows/agency-check.yml"
  else
    cp "$AGENCY_ROOT/templates/github-workflows/agency-check.yml" "$dir/.github/workflows/agency-check.yml"
    echo "✓ 写入 $dir/.github/workflows/agency-check.yml"
  fi

  rm -rf "$dir/.agents/skills/agency-check"
  cp -R "$AGENCY_ROOT/skills/agency-check" "$dir/.agents/skills/agency-check"
  echo "✓ 写入 $dir/.agents/skills/agency-check/"

  if [ -d "$dir/.git" ] || git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if [ -f "$dir/.husky/pre-commit" ]; then
      echo "⚠ 检测到 husky，未设置 core.hooksPath。请把 .githooks/pre-commit 中的调用并进 .husky/pre-commit。"
    else
      git -C "$dir" config core.hooksPath .githooks
      echo "✓ 本 clone 已 git config core.hooksPath .githooks"
    fi
  fi

  echo
  echo "完成。请提交："
  echo "  agency-check.conf .agency-check/ .githooks/ .github/workflows/agency-check.yml .agents/skills/agency-check/"
  echo "同事 clone 后（可选本机 hook）：git config core.hooksPath .githooks"
  echo "未设 hook 时仍靠 CI 强制。不要用 --all 当提交门禁。"
}

# ---------- 参数 ----------

MODE=""
PROJECT_DIR=""
BASE=""
CLI_ENABLE=""
CLI_DISABLE=""
FORCE=0
DO_INSTALL=0
DO_LIST=0

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0;;
    --dir)
      PROJECT_DIR="${2:-}"; shift 2;;
    --staged) MODE="staged"; shift;;
    --base)
      MODE="base"; BASE="${2:-}"; shift 2;;
    --all) MODE="all"; shift;;
    --enable)
      CLI_ENABLE="$(add_csv "$CLI_ENABLE" "${2:-}")"; shift 2;;
    --disable)
      CLI_DISABLE="$(add_csv "$CLI_DISABLE" "${2:-}")"; shift 2;;
    --install)
      DO_INSTALL=1
      if [ -n "${2:-}" ] && [ "${2#--}" = "$2" ]; then
        PROJECT_DIR="$2"; shift 2
      else
        shift
      fi
      ;;
    --force) FORCE=1; shift;;
    --list) DO_LIST=1; shift;;
    --)
      shift; break;;
    -*)
      echo "未知参数: $1" >&2; usage >&2; exit 2;;
    *)
      if [ -z "$PROJECT_DIR" ]; then
        PROJECT_DIR="$1"; shift
      else
        echo "多余参数: $1" >&2; exit 2
      fi
      ;;
  esac
done

[ -n "$PROJECT_DIR" ] || PROJECT_DIR="$(pwd)"
[ -d "$PROJECT_DIR" ] || { echo "目录不存在: $PROJECT_DIR" >&2; exit 2; }
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

if git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  GIT_ROOT="$(git -C "$PROJECT_DIR" rev-parse --show-toplevel)"
else
  GIT_ROOT=""
fi

load_conf "$PROJECT_DIR/agency-check.conf"

if [ "$DO_INSTALL" = "1" ]; then
  cmd_install "$PROJECT_DIR"
  exit 0
fi

if [ "$DO_LIST" = "1" ]; then
  list_checks
  exit 0
fi

if [ -z "$MODE" ]; then
  if [ -n "$GIT_ROOT" ]; then
    MODE="work"
  else
    echo "不是 git 仓库。指定 --all 做全量扫描，或先 git init。" >&2
    exit 2
  fi
fi

if [ "$MODE" != "all" ] && [ -z "$GIT_ROOT" ]; then
  echo "增量模式需要 git 仓库。" >&2
  exit 2
fi

if [ "$MODE" = "base" ]; then
  [ -n "$BASE" ] || BASE="${CONF_BASE:-origin/main}"
  if ! git_in rev-parse --verify "$BASE" >/dev/null 2>&1; then
    echo "找不到基线 ref: $BASE" >&2
    exit 2
  fi
fi

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT
collect_added "$TMP"

scan "$TMP"

echo "agency-check: mode=$MODE result=$([ "$FAIL_N" -eq 0 ] && echo PASS || echo FAIL) hits=$FAIL_N checks=$ENABLED_IDS${HIT_IDS:+ hit_ids=$HIT_IDS}${BASE:+ base=$BASE}"

[ "$FAIL_N" -eq 0 ]
