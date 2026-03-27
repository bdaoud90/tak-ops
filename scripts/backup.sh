#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: backup.sh [--source DIR] [--dest DIR] [--name PREFIX] [--help]

Create a compressed TAK backup archive and a SHA-256 checksum file.
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

command -v sha256sum >/dev/null 2>&1 || { echo "ERROR: sha256sum is required" >&2; exit 1; }
[[ -d "$SRC_DIR" ]] || { echo "ERROR: Source directory not found: $SRC_DIR" >&2; exit 1; }
mkdir -p "$DEST_DIR"
[[ -w "$DEST_DIR" ]] || { echo "ERROR: Destination not writable: $DEST_DIR" >&2; exit 1; }

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="${DEST_DIR}/${NAME_PREFIX}-${STAMP}.tar.gz"
CHECKSUM_FILE="${OUT}.sha256"

tar -czf "$OUT" "$SRC_DIR"
(
  cd "$(dirname "$OUT")"
  sha256sum "$(basename "$OUT")" > "$(basename "$CHECKSUM_FILE")"
)

echo "[backup] archive: $OUT"
echo "[backup] checksum: $CHECKSUM_FILE"
