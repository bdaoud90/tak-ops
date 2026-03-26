#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: restore.sh --archive FILE [--checksum FILE] [--destination DIR] [--live-restore] [--skip-checksum] [--help]

Restore backup archive safely.
Default behavior extracts to a staging directory.
Use --live-restore to permit extraction to live paths.
USAGE
}

ARCHIVE=""
CHECKSUM_FILE=""
DEST_DIR=""
LIVE_RESTORE="false"
SKIP_CHECKSUM="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --archive) ARCHIVE="$2"; shift 2 ;;
    --checksum) CHECKSUM_FILE="$2"; shift 2 ;;
    --destination) DEST_DIR="$2"; shift 2 ;;
    --live-restore) LIVE_RESTORE="true"; shift ;;
    --skip-checksum) SKIP_CHECKSUM="true"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[[ -n "$ARCHIVE" ]] || { echo "ERROR: --archive is required" >&2; exit 1; }
[[ -f "$ARCHIVE" ]] || { echo "ERROR: Archive not found: $ARCHIVE" >&2; exit 1; }
command -v sha256sum >/dev/null 2>&1 || { echo "ERROR: sha256sum required" >&2; exit 1; }

if [[ -z "$CHECKSUM_FILE" ]]; then
  CHECKSUM_FILE="${ARCHIVE}.sha256"
fi

if [[ "$SKIP_CHECKSUM" != "true" ]]; then
  [[ -f "$CHECKSUM_FILE" ]] || { echo "ERROR: Checksum file missing: $CHECKSUM_FILE" >&2; exit 1; }
  echo "[restore] verifying checksum"
  sha256sum -c "$CHECKSUM_FILE"
else
  echo "[restore] WARNING: checksum verification skipped"
fi

if [[ "$LIVE_RESTORE" == "true" ]]; then
  DEST_DIR="${DEST_DIR:-/}"
  echo "#############################################"
  echo "# WARNING: LIVE RESTORE ENABLED"
  echo "# You should stop affected services first."
  echo "#############################################"
else
  DEST_DIR="${DEST_DIR:-/tmp/tak-restore-$(date -u +%Y%m%dT%H%M%SZ)}"
  echo "[restore] safe mode: restoring to staging directory $DEST_DIR"
fi

mkdir -p "$DEST_DIR"
[[ -w "$DEST_DIR" ]] || { echo "ERROR: Destination not writable: $DEST_DIR" >&2; exit 1; }

tar -xzf "$ARCHIVE" -C "$DEST_DIR"

echo "[restore] completed"
if [[ "$LIVE_RESTORE" != "true" ]]; then
  echo "[restore] Manual operator step: inspect staged contents before copying into live paths"
fi
