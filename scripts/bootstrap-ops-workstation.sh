#!/usr/bin/env bash
set -euo pipefail

# Usage notes:
# - Run from the repository root: ./scripts/bootstrap-ops-workstation.sh
# - This script only creates non-sensitive local directories and non-secret template files.
# - Existing files are never overwritten.

usage() {
  cat <<'USAGE'
Usage: bootstrap-ops-workstation.sh [--repo-root PATH] [--help]

Prepare an operator workstation for local TAK operations.

What this script does:
  - Verifies required tools: python3, pip, git
  - Warns (does not fail) for optional tools: terraform, ansible, jq, curl, make
  - Creates non-sensitive local working directories
  - Copies env templates only when destination files are missing

Options:
  --repo-root PATH  Repository root (default: current working directory)
  -h, --help        Show this help message
USAGE
}

REPO_ROOT="$(pwd)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-root)
      [[ $# -ge 2 ]] || { echo "ERROR: --repo-root requires a value" >&2; exit 2; }
      REPO_ROOT="$2"
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

cd "$REPO_ROOT"

echo "[bootstrap-ops] repo root: $REPO_ROOT"

required_tools=(python3 pip git)
optional_tools=(terraform ansible jq curl make)

for tool in "${required_tools[@]}"; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "ERROR: Required tool not found: $tool" >&2
    exit 1
  fi
  echo "[bootstrap-ops] found required tool: $tool"
done

for tool in "${optional_tools[@]}"; do
  if command -v "$tool" >/dev/null 2>&1; then
    echo "[bootstrap-ops] found optional tool: $tool"
  else
    echo "WARNING: Optional tool not found: $tool" >&2
  fi
done

work_dirs=(
  ".local"
  ".local/ops"
  ".local/ops/artifacts"
  ".local/ops/logs"
  ".local/ops/tmp"
)

for dir in "${work_dirs[@]}"; do
  if [[ -d "$dir" ]]; then
    echo "[bootstrap-ops] exists: $dir"
  else
    mkdir -p "$dir"
    echo "[bootstrap-ops] created: $dir"
  fi
done

template_pairs=(
  ".env.example:.env"
  "infra/terraform/environments/dev/terraform.tfvars.example:infra/terraform/environments/dev/terraform.tfvars"
  "infra/terraform/environments/prod/terraform.tfvars.example:infra/terraform/environments/prod/terraform.tfvars"
)

for pair in "${template_pairs[@]}"; do
  src="${pair%%:*}"
  dst="${pair##*:}"

  if [[ ! -f "$src" ]]; then
    echo "WARNING: Template source missing, skipped: $src" >&2
    continue
  fi

  if [[ -e "$dst" ]]; then
    echo "[bootstrap-ops] preserved existing file: $dst"
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "[bootstrap-ops] created template file: $dst (from $src)"
  fi
done

cat <<'NEXT'

[bootstrap-ops] Next steps:
  1) Review and update local configuration files (.env and terraform.tfvars).
  2) Validate configuration: ./scripts/validate-config.sh
  3) Run bootstrap flow as needed:
       - Server prep: ./scripts/bootstrap-server.sh --env-file .env
       - Edge bootstrap: ./scripts/bootstrap-edge.sh

No hidden mutations were performed; all changes are listed above.
NEXT
