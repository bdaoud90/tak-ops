#!/usr/bin/env python3
"""Convert normalized report CSV records to GeoJSON FeatureCollection."""

from __future__ import annotations

import argparse
import csv
import json
import sys
from pathlib import Path


def parse_args() -> argparse.Namespace:
    """Parse input CSV and output GeoJSON path arguments."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path, help="Input CSV path")
    parser.add_argument("output", type=Path, help="Output GeoJSON path")
    return parser.parse_args()


def parse_float(value: str, column: str, row_number: int) -> float:
    """Parse a float, raising a row/column-contextual error on bad input."""
    try:
        return float(value)
    except ValueError as exc:
        raise ValueError(f"row {row_number}: invalid {column} value '{value}'") from exc


def main() -> int:
    """Convert the input CSV (requires lat/lon columns) to a GeoJSON file."""
    args = parse_args()
    if not args.input.is_file():
        print(f"ERROR: input file not found: {args.input}", file=sys.stderr)
        return 1

    features: list[dict[str, object]] = []
    with args.input.open("r", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        required = {"lat", "lon"}
        if reader.fieldnames is None or not required.issubset(set(reader.fieldnames)):
            print("ERROR: input CSV must include lat/lon columns", file=sys.stderr)
            return 1

        for row_number, row in enumerate(reader, start=2):
            try:
                lat = parse_float(row["lat"], "lat", row_number)
                lon = parse_float(row["lon"], "lon", row_number)
            except ValueError as err:
                print(f"ERROR: {err}", file=sys.stderr)
                return 1

            props = {k: row[k] for k in sorted(row.keys()) if k not in {"lat", "lon"}}
            features.append(
                {
                    "type": "Feature",
                    "geometry": {"type": "Point", "coordinates": [lon, lat]},
                    "properties": props,
                }
            )

    out = {"type": "FeatureCollection", "features": features}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(out, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"Wrote {len(features)} features to {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
