#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: create-env.sh [--force] [--template PATH] [--output PATH] [--help]

Create local .env file from template.
USAGE
}

FORCE="false"
TEMPLATE=".env.example"
OUTPUT=".env"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE="true"; shift ;;
    --template)
      [[ $# -ge 2 ]] || { echo "ERROR: --template requires a value" >&2; exit 2; }
      TEMPLATE="$2"; shift 2 ;;
    --output)
      [[ $# -ge 2 ]] || { echo "ERROR: --output requires a value" >&2; exit 2; }
      OUTPUT="$2"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "ERROR: Unknown argument: $1" >&2
      usage >&2
      exit 2 ;;
  esac
done

[[ -f "$TEMPLATE" ]] || { echo "ERROR: Template not found: $TEMPLATE" >&2; exit 1; }
if [[ -f "$OUTPUT" && "$FORCE" != "true" ]]; then
  echo "ERROR: $OUTPUT exists. Use --force to overwrite." >&2
  exit 1
fi

cp "$TEMPLATE" "$OUTPUT"
echo "[create-env] wrote $OUTPUT from $TEMPLATE"
echo "[create-env] Manual operator step: update secrets and environment-specific values."
