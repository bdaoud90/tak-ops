#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: restore.sh --archive FILE [--destination DIR] [--help]

Restore TAK data from a backup archive.
USAGE
}

ARCHIVE=""
DEST_DIR="/"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --archive)
      [[ $# -ge 2 ]] || { echo "ERROR: --archive requires a value" >&2; exit 2; }
      ARCHIVE="$2"; shift 2 ;;
    --destination)
      [[ $# -ge 2 ]] || { echo "ERROR: --destination requires a value" >&2; exit 2; }
      DEST_DIR="$2"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "ERROR: Unknown argument: $1" >&2
      usage >&2
      exit 2 ;;
  esac
done

[[ -n "$ARCHIVE" ]] || { echo "ERROR: --archive is required" >&2; exit 1; }
[[ -f "$ARCHIVE" ]] || { echo "ERROR: Archive not found: $ARCHIVE" >&2; exit 1; }
[[ -d "$DEST_DIR" ]] || { echo "ERROR: Destination directory not found: $DEST_DIR" >&2; exit 1; }

echo "[restore] extracting $ARCHIVE into $DEST_DIR"
tar -xzf "$ARCHIVE" -C "$DEST_DIR"
echo "[restore] completed"
