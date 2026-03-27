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
import sys

try:
    import yaml
except ImportError as exc:
    print("ERROR: PyYAML is required. Install with: pip install PyYAML", file=sys.stderr)
    raise SystemExit(1) from exc

path = Path(sys.argv[1])

try:
    data = yaml.safe_load(path.read_text(encoding="utf-8"))
except yaml.YAMLError as exc:
    print(f"ERROR: Invalid YAML in {path}: {exc}", file=sys.stderr)
    raise SystemExit(1)

if not isinstance(data, dict):
    print("ERROR: Config root must be a mapping/object", file=sys.stderr)
    raise SystemExit(1)

required_top = ["pilot", "backup"]
missing_top = [k for k in required_top if k not in data]
if missing_top:
    print(f"ERROR: Missing top-level sections: {', '.join(missing_top)}", file=sys.stderr)
    raise SystemExit(1)

pilot = data.get("pilot")
backup = data.get("backup")

if not isinstance(pilot, dict):
    print("ERROR: pilot section must be a mapping/object", file=sys.stderr)
    raise SystemExit(1)
if not isinstance(backup, dict):
    print("ERROR: backup section must be a mapping/object", file=sys.stderr)
    raise SystemExit(1)

required_pilot = {
    "environment": str,
    "tak_fqdn": str,
    "cloud": dict,
    "edge": dict,
}
required_backup = {
    "enabled": bool,
    "destination": str,
}

for key, expected_type in required_pilot.items():
    if key not in pilot:
        print(f"ERROR: pilot.{key} is required", file=sys.stderr)
        raise SystemExit(1)
    if not isinstance(pilot[key], expected_type):
        print(f"ERROR: pilot.{key} must be of type {expected_type.__name__}", file=sys.stderr)
        raise SystemExit(1)

for key, expected_type in required_backup.items():
    if key not in backup:
        print(f"ERROR: backup.{key} is required", file=sys.stderr)
        raise SystemExit(1)
    if not isinstance(backup[key], expected_type):
        print(f"ERROR: backup.{key} must be of type {expected_type.__name__}", file=sys.stderr)
        raise SystemExit(1)

for section_name, section, required_keys in (
    ("pilot.cloud", pilot["cloud"], {"provider": str, "region": str}),
    ("pilot.edge", pilot["edge"], {"hostname": str, "mode": str}),
):
    for key, expected_type in required_keys.items():
        if key not in section:
            print(f"ERROR: {section_name}.{key} is required", file=sys.stderr)
            raise SystemExit(1)
        if not isinstance(section[key], expected_type):
            print(f"ERROR: {section_name}.{key} must be of type {expected_type.__name__}", file=sys.stderr)
            raise SystemExit(1)

tak_fqdn = pilot["tak_fqdn"].strip()
if not tak_fqdn:
    print("ERROR: pilot.tak_fqdn must not be empty", file=sys.stderr)
    raise SystemExit(1)
if tak_fqdn.endswith("example.com"):
    print("WARNING: pilot.tak_fqdn appears to be a placeholder")

print("Config validation passed")
PY
