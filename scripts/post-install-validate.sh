#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: post-install-validate.sh [--service NAME] [--service NAME] [--path PATH] [--path PATH] [--help]

Placeholder post-install validator for manually installed TAK components.
Checks declared services and required file paths.
USAGE
}

SERVICES=()
PATHS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --service) SERVICES+=("$2"); shift 2 ;;
    --path) PATHS+=("$2"); shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ ${#SERVICES[@]} -eq 0 && ${#PATHS[@]} -eq 0 ]]; then
  echo "ERROR: at least one --service or --path check is required" >&2
  exit 1
fi

for svc in "${SERVICES[@]}"; do
  if systemctl is-active --quiet "$svc"; then
    echo "[PASS] service active: $svc"
  else
    echo "[FAIL] service inactive or unknown: $svc" >&2
  fi
done

for p in "${PATHS[@]}"; do
  if [[ -e "$p" ]]; then
    echo "[PASS] path exists: $p"
  else
    echo "[FAIL] path missing: $p" >&2
  fi
done

echo "[post-install-validate] Review output and map checks to your TAK deployment specifics"
