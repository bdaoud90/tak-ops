#!/usr/bin/env bash
set -euo pipefail

# Usage notes:
# - Run from repository root to create a portable operator bundle archive.
# - This packages only docs/scripts/examples/tooling content.
# - Secret material, state files, and TAK/proprietary binaries are excluded by policy.

usage() {
  cat <<'USAGE'
Usage: package-operator-bundle.sh [--output-dir PATH] [--name NAME] [--include PATTERN] [--help]

Create a sanitized operator bundle tarball.

Defaults:
  output dir: .local/ops/artifacts
  archive name: tak-operator-bundle-YYYYMMDD-HHMMSS.tar.gz
  include set: docs/** scripts/** examples/** tooling/**

Options:
  --output-dir PATH  Destination directory for archive
  --name NAME        Archive file name (must end in .tar.gz)
  --include PATTERN  Additional include pattern (repeatable)
  -h, --help         Show this help message
USAGE
}

OUTPUT_DIR=".local/ops/artifacts"
ARCHIVE_NAME="tak-operator-bundle-$(date -u +%Y%m%d-%H%M%S).tar.gz"
EXTRA_INCLUDES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output-dir)
      [[ $# -ge 2 ]] || { echo "ERROR: --output-dir requires a value" >&2; exit 2; }
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --name)
      [[ $# -ge 2 ]] || { echo "ERROR: --name requires a value" >&2; exit 2; }
      ARCHIVE_NAME="$2"
      shift 2
      ;;
    --include)
      [[ $# -ge 2 ]] || { echo "ERROR: --include requires a value" >&2; exit 2; }
      EXTRA_INCLUDES+=("$2")
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ "$ARCHIVE_NAME" != *.tar.gz ]]; then
  echo "ERROR: Archive name must end in .tar.gz" >&2
  exit 2
fi

allowed_roots_regex='^(docs|scripts|examples|tooling)(/|$)'
forbidden_include_regex='(^|/)(\.env(\.|$)|secrets?|private|proprietary|state|terraform\.tfstate|\.terraform|takserver|tak-server)(/|$)'

base_includes=(docs scripts examples tooling)
all_includes=("${base_includes[@]}" "${EXTRA_INCLUDES[@]}")

for pattern in "${all_includes[@]}"; do
  if [[ "$pattern" == *".."* ]]; then
    echo "ERROR: Unsafe include pattern (path traversal): $pattern" >&2
    exit 1
  fi
  if [[ ! "$pattern" =~ $allowed_roots_regex ]]; then
    echo "ERROR: Unsafe include pattern (outside allowed roots): $pattern" >&2
    exit 1
  fi
  if [[ "$pattern" =~ $forbidden_include_regex ]]; then
    echo "ERROR: Unsafe include pattern (forbidden content): $pattern" >&2
    exit 1
  fi
done

shopt -s nullglob
existing_includes=()
for path in "${all_includes[@]}"; do
  if compgen -G "$path" >/dev/null 2>&1 || [[ -d "$path" || -f "$path" ]]; then
    existing_includes+=("$path")
  fi
done
shopt -u nullglob

if [[ ${#existing_includes[@]} -eq 0 ]]; then
  echo "ERROR: Nothing to package from allowed include set." >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
archive_path="$OUTPUT_DIR/$ARCHIVE_NAME"

if [[ -e "$archive_path" ]]; then
  echo "ERROR: Archive already exists: $archive_path" >&2
  exit 1
fi

echo "[package-bundle] creating archive: $archive_path"

exclude_args=(
  --exclude='.env'
  --exclude='**/.env'
  --exclude='**/.env.*'
  --exclude='**/*secret*'
  --exclude='**/*private*'
  --exclude='**/*proprietary*'
  --exclude='**/*.tfstate'
  --exclude='**/*.tfstate.*'
  --exclude='**/.terraform/**'
  --exclude='**/*.pem'
  --exclude='**/*.key'
  --exclude='**/*.p12'
  --exclude='**/*.jks'
  --exclude='**/takserver*'
  --exclude='**/tak-server*'
  --exclude='**/*.rpm'
  --exclude='**/*.deb'
  --exclude='**/*.jar'
)

tar -czf "$archive_path" "${exclude_args[@]}" "${existing_includes[@]}"

file_count=$(tar -tzf "$archive_path" | wc -l | tr -d ' ')
summary_file="$(mktemp)"
tar -tzf "$archive_path" > "$summary_file"

cat <<SUMMARY
[package-bundle] artifact: $archive_path
[package-bundle] files archived: $file_count
[package-bundle] included roots: ${existing_includes[*]}
[package-bundle] first 20 entries:
SUMMARY
head -n 20 "$summary_file"
rm -f "$summary_file"
