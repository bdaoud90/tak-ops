#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: restore.sh --archive FILE [--destination DIR] [--live-restore] [--help]

Restore TAK data from a backup archive.

Defaults to safe staging extraction in /var/tmp/tak-restore.
Use --live-restore to permit extraction directly into '/'.
USAGE
}

ARCHIVE=""
DEST_DIR="/var/tmp/tak-restore"
LIVE_RESTORE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --archive)
      [[ $# -ge 2 ]] || { echo "ERROR: --archive requires a value" >&2; exit 2; }
      ARCHIVE="$2"; shift 2 ;;
    --destination)
      [[ $# -ge 2 ]] || { echo "ERROR: --destination requires a value" >&2; exit 2; }
      DEST_DIR="$2"; shift 2 ;;
    --live-restore)
      LIVE_RESTORE=true; shift ;;
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

if [[ "$DEST_DIR" == "/" && "$LIVE_RESTORE" != "true" ]]; then
  echo "ERROR: Refusing to restore into '/' without --live-restore" >&2
  exit 1
fi

if [[ "$DEST_DIR" == "/" ]]; then
  echo "WARNING: LIVE restore into '/' requested. This can overwrite system files." >&2
else
  mkdir -p "$DEST_DIR"
fi

[[ -d "$DEST_DIR" ]] || { echo "ERROR: Destination directory not found: $DEST_DIR" >&2; exit 1; }
[[ -w "$DEST_DIR" ]] || { echo "ERROR: Destination directory is not writable: $DEST_DIR" >&2; exit 1; }

echo "[restore] extracting $ARCHIVE into $DEST_DIR"
tar -xzf "$ARCHIVE" -C "$DEST_DIR"
echo "[restore] completed"
