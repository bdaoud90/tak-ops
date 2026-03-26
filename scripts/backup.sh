#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: backup.sh [--source DIR] [--dest DIR] [--name PREFIX] [--help]

Create compressed backup archive and SHA256 checksum.
USAGE
}

SRC_DIR="/opt/tak"
DEST_DIR="/var/backups/tak"
NAME_PREFIX="tak"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source) SRC_DIR="$2"; shift 2 ;;
    --dest) DEST_DIR="$2"; shift 2 ;;
    --name) NAME_PREFIX="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

command -v sha256sum >/dev/null 2>&1 || { echo "ERROR: sha256sum is required" >&2; exit 1; }
[[ -d "$SRC_DIR" ]] || { echo "ERROR: Source directory not found: $SRC_DIR" >&2; exit 1; }
mkdir -p "$DEST_DIR"
[[ -w "$DEST_DIR" ]] || { echo "ERROR: Destination not writable: $DEST_DIR" >&2; exit 1; }

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
ARCHIVE="${DEST_DIR}/${NAME_PREFIX}-${STAMP}.tar.gz"
CHECKSUM_FILE="${ARCHIVE}.sha256"

echo "[backup] creating archive from $SRC_DIR"
tar -czf "$ARCHIVE" "$SRC_DIR"
sha256sum "$ARCHIVE" > "$CHECKSUM_FILE"

echo "[backup] archive:   $ARCHIVE"
echo "[backup] checksum:  $CHECKSUM_FILE"
echo "[backup] Manual operator step: move both files to approved offsite location"
