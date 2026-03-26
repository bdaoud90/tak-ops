#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: validate-config.sh [--config PATH] [--help]

Structured validation for pilot YAML config.
Validates required keys, types, and placeholder values.
USAGE
}

CONFIG_FILE="config/pilot.yaml"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config) CONFIG_FILE="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[[ -f "$CONFIG_FILE" ]] || { echo "ERROR: Missing config file: $CONFIG_FILE" >&2; exit 1; }

python3 - "$CONFIG_FILE" <<'PY'
from __future__ import annotations

import re
import sys
from pathlib import Path
from typing import Any


def parse_scalar(value: str) -> Any:
    v = value.strip()
    if v in {"true", "false"}:
        return v == "true"
    if re.fullmatch(r"-?\d+", v):
        return int(v)
    return v.strip('"').strip("'")


def fallback_parse_yaml(text: str) -> dict[str, Any]:
    root: dict[str, Any] = {}
    stack: list[tuple[int, dict[str, Any]]] = [(-1, root)]
    for lineno, raw in enumerate(text.splitlines(), start=1):
        line = raw.split("#", 1)[0].rstrip()
        if not line.strip():
            continue
        indent = len(line) - len(line.lstrip(" "))
        if ":" not in line:
            raise ValueError(f"line {lineno}: expected key:value")
        key, rest = line.strip().split(":", 1)
        while stack and indent <= stack[-1][0]:
            stack.pop()
        if not stack:
            raise ValueError(f"line {lineno}: indentation error")
        parent = stack[-1][1]
        if rest.strip() == "":
            parent[key] = {}
            stack.append((indent, parent[key]))
        else:
            parent[key] = parse_scalar(rest)
    return root


def load_yaml(path: Path) -> dict[str, Any]:
    text = path.read_text(encoding="utf-8")
    try:
        import yaml  # type: ignore
        data = yaml.safe_load(text)
        if not isinstance(data, dict):
            raise ValueError("config root must be mapping")
        return data
    except ModuleNotFoundError:
        return fallback_parse_yaml(text)


def require(mapping: dict[str, Any], key: str, expected_type: type) -> Any:
    if key not in mapping:
        raise ValueError(f"missing key: {key}")
    value = mapping[key]
    if not isinstance(value, expected_type):
        raise ValueError(f"key {key} must be {expected_type.__name__}")
    return value


path = Path(sys.argv[1])
cfg = load_yaml(path)

pilot = require(cfg, "pilot", dict)
backup = require(cfg, "backup", dict)

env = require(pilot, "environment", str)
fqdn = require(pilot, "tak_fqdn", str)
cloud = require(pilot, "cloud", dict)
edge = require(pilot, "edge", dict)

require(cloud, "provider", str)
require(cloud, "region", str)
require(edge, "hostname", str)
require(edge, "mode", str)

require(backup, "enabled", bool)
dest = require(backup, "destination", str)

if env not in {"dev", "prod"}:
    raise ValueError("pilot.environment must be dev or prod")

warnings: list[str] = []
if fqdn.endswith("example.com"):
    warnings.append("tak_fqdn appears to be placeholder")
if dest.startswith("/tmp"):
    warnings.append("backup.destination should not be a temporary path for pilot ops")

print("Config validation passed")
for warning in warnings:
    print(f"WARNING: {warning}")
PY
