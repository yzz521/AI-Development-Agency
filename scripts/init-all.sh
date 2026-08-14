#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENCY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT_DIR="${1:-$(cd "$AGENCY_ROOT/.." && pwd)}"
RECURSIVE="${RECURSIVE:-0}"
ROOT_DIR="$(cd "$ROOT_DIR" 2>/dev/null && pwd)" || { echo "错误：目录不存在：$1"; exit 1; }

echo "Agency: $AGENCY_ROOT"; echo "Workspace: $ROOT_DIR"; echo "Recursive: $RECURSIVE"; echo
is_project() {
  d="$1"; [ "$d" = "$AGENCY_ROOT" ] && return 1
  [ -f "$d/pom.xml" ] || [ -f "$d/build.gradle" ] || [ -f "$d/build.gradle.kts" ] || [ -f "$d/package.json" ] || [ -f "$d/pyproject.toml" ] || [ -f "$d/requirements.txt" ] || [ -d "$d/.git" ]
}
count=0; skip=0
if [ "$RECURSIVE" = "1" ]; then
  while IFS= read -r -d '' d; do
    case "$d" in */.git|*/.git/*|*/node_modules|*/node_modules/*|*/target|*/target/*|*/build|*/build/*|*/dist|*/dist/*|*/.idea|*/.idea/*|*/.venv|*/.venv/*) continue;; esac
    if is_project "$d"; then "$SCRIPT_DIR/init-project.sh" "$d"; count=$((count+1)); fi
  done < <(find "$ROOT_DIR" -type d -print0)
else
  while IFS= read -r -d '' d; do
    if is_project "$d"; then "$SCRIPT_DIR/init-project.sh" "$d"; count=$((count+1)); else skip=$((skip+1)); fi
  done < <(find "$ROOT_DIR" -mindepth 1 -maxdepth 1 -type d -print0)
fi
echo; echo "完成：初始化 $count 个项目，跳过 $skip 个目录"
