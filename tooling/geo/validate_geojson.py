#!/usr/bin/env python3
"""Validate a GeoJSON FeatureCollection with Point geometries."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path, help="GeoJSON file path")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if not args.input.is_file():
        print(f"ERROR: input file not found: {args.input}", file=sys.stderr)
        return 1

    try:
        doc = json.loads(args.input.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        print(f"ERROR: invalid JSON: {exc}", file=sys.stderr)
        return 1

    if doc.get("type") != "FeatureCollection":
        print("ERROR: root GeoJSON type must be FeatureCollection", file=sys.stderr)
        return 1

    features = doc.get("features")
    if not isinstance(features, list):
        print("ERROR: features must be a list", file=sys.stderr)
        return 1

    for idx, feature in enumerate(features, start=1):
        if feature.get("type") != "Feature":
            print(f"ERROR: feature #{idx} has invalid type", file=sys.stderr)
            return 1
        geom = feature.get("geometry", {})
        if geom.get("type") != "Point":
            print(f"ERROR: feature #{idx} geometry must be Point", file=sys.stderr)
            return 1
        coords = geom.get("coordinates")
        if not (isinstance(coords, list) and len(coords) == 2):
            print(f"ERROR: feature #{idx} coordinates must be [lon, lat]", file=sys.stderr)
            return 1

    print(f"GeoJSON validation passed ({len(features)} features)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
