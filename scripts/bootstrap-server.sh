#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: bootstrap-server.sh [--env-file PATH] [--help]

Prepare the local operator context for server bootstrap.

Options:
  --env-file PATH   Path to environment file (default: .env)
  -h, --help        Show this help message
USAGE
}

ENV_FILE=".env"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-file)
      [[ $# -ge 2 ]] || { echo "ERROR: --env-file requires a value" >&2; exit 2; }
      ENV_FILE="$2"
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

[[ -f "$ENV_FILE" ]] || { echo "ERROR: Missing env file: $ENV_FILE" >&2; exit 1; }
# shellcheck disable=SC1090
source "$ENV_FILE"

: "${TAK_FQDN:?ERROR: TAK_FQDN required in ${ENV_FILE}}"
: "${TAK_MANUAL_STAGING_DIR:=/opt/tak/manual}"

echo "[bootstrap-server] Target FQDN: ${TAK_FQDN}"
echo "[bootstrap-server] Manual staging dir: ${TAK_MANUAL_STAGING_DIR}"
echo "[bootstrap-server] Manual operator step: stage restricted TAK artifacts before install"
