#!/usr/bin/env python3
"""Normalize CSV report records for downstream geospatial processing."""

from __future__ import annotations

import argparse
import csv
import sys
from pathlib import Path


EXPECTED_FIELDS = ["id", "title", "lat", "lon", "timestamp"]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path, help="Input CSV path")
    parser.add_argument("output", type=Path, help="Output CSV path")
    return parser.parse_args()


def clean(value: str) -> str:
    return " ".join(value.strip().split())


def main() -> int:
    args = parse_args()
    if not args.input.is_file():
        print(f"ERROR: input file not found: {args.input}", file=sys.stderr)
        return 1

    rows: list[dict[str, str]] = []
    with args.input.open("r", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        if reader.fieldnames is None:
            print("ERROR: input CSV has no header", file=sys.stderr)
            return 1

        missing = [f for f in EXPECTED_FIELDS if f not in reader.fieldnames]
        if missing:
            print(f"ERROR: missing expected columns: {', '.join(missing)}", file=sys.stderr)
            return 1

        for idx, row in enumerate(reader, start=2):
            normalized = {k: clean(row.get(k, "")) for k in EXPECTED_FIELDS}
            if not normalized["id"]:
                print(f"WARN: row {idx} missing id; skipping", file=sys.stderr)
                continue
            normalized["title"] = normalized["title"].lower()
            rows.append(normalized)

    rows.sort(key=lambda item: (item["timestamp"], item["id"]))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=EXPECTED_FIELDS)
        writer.writeheader()
        writer.writerows(rows)

    print(f"Normalized {len(rows)} rows to {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
