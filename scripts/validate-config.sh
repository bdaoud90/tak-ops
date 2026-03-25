#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: validate-config.sh [--config PATH] [--help]

Validate required keys and basic values in pilot config YAML.
USAGE
}

CONFIG_FILE="config/pilot.yaml"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config)
      [[ $# -ge 2 ]] || { echo "ERROR: --config requires a value" >&2; exit 2; }
      CONFIG_FILE="$2"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "ERROR: Unknown argument: $1" >&2
      usage >&2
      exit 2 ;;
  esac
done

[[ -f "$CONFIG_FILE" ]] || { echo "ERROR: Missing config file: $CONFIG_FILE" >&2; exit 1; }

python3 - "$CONFIG_FILE" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
required_markers = ["pilot:", "environment:", "tak_fqdn:", "backup:", "destination:"]
missing = [item for item in required_markers if item not in text]
if missing:
    print(f"ERROR: Missing required keys: {', '.join(missing)}", file=sys.stderr)
    raise SystemExit(1)

fqdn_match = re.search(r"^\s*tak_fqdn:\s*(\S+)\s*$", text, flags=re.MULTILINE)
if not fqdn_match:
    print("ERROR: tak_fqdn value not found", file=sys.stderr)
    raise SystemExit(1)

if fqdn_match.group(1).endswith("example.com"):
    print("WARNING: tak_fqdn appears to be a placeholder")

print("Config validation passed")
PY
