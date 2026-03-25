#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: backup.sh [--source DIR] [--dest DIR] [--name PREFIX] [--help]

Create a compressed TAK backup archive.
USAGE
}

SRC_DIR="/opt/tak"
DEST_DIR="/var/backups/tak"
NAME_PREFIX="tak"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)
      [[ $# -ge 2 ]] || { echo "ERROR: --source requires a value" >&2; exit 2; }
      SRC_DIR="$2"; shift 2 ;;
    --dest)
      [[ $# -ge 2 ]] || { echo "ERROR: --dest requires a value" >&2; exit 2; }
      DEST_DIR="$2"; shift 2 ;;
    --name)
      [[ $# -ge 2 ]] || { echo "ERROR: --name requires a value" >&2; exit 2; }
      NAME_PREFIX="$2"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "ERROR: Unknown argument: $1" >&2
      usage >&2
      exit 2 ;;
  esac
done

[[ -d "$SRC_DIR" ]] || { echo "ERROR: Source directory not found: $SRC_DIR" >&2; exit 1; }
mkdir -p "$DEST_DIR"
[[ -w "$DEST_DIR" ]] || { echo "ERROR: Destination not writable: $DEST_DIR" >&2; exit 1; }

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="${DEST_DIR}/${NAME_PREFIX}-${STAMP}.tar.gz"

tar -czf "$OUT" "$SRC_DIR"
echo "[backup] created: $OUT"
