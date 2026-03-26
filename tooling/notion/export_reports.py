#!/usr/bin/env python3
"""Export NDJSON notion-style report records to deterministic CSV output."""

from __future__ import annotations

import argparse
import csv
import json
import sys
from pathlib import Path
from typing import Any

FIELDS = ["id", "title", "lat", "lon", "timestamp"]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path, help="Input NDJSON file")
    parser.add_argument("output", type=Path, help="Output CSV path")
    parser.add_argument("--strict", action="store_true", help="Fail on malformed JSON lines")
    return parser.parse_args()


def normalize_record(obj: dict[str, Any]) -> dict[str, str]:
    return {
        "id": str(obj.get("id", "")).strip(),
        "title": str(obj.get("title", "")).strip(),
        "lat": str(obj.get("lat", "")).strip(),
        "lon": str(obj.get("lon", "")).strip(),
        "timestamp": str(obj.get("timestamp", "")).strip(),
    }


def main() -> int:
    args = parse_args()
    if not args.input.is_file():
        print(f"ERROR: input file not found: {args.input}", file=sys.stderr)
        return 1

    rows: list[dict[str, str]] = []
    with args.input.open("r", encoding="utf-8") as handle:
        for idx, line in enumerate(handle, start=1):
            raw = line.strip()
            if not raw:
                continue
            try:
                obj = json.loads(raw)
            except json.JSONDecodeError as exc:
                message = f"WARN: line {idx} invalid JSON: {exc}"
                if args.strict:
                    print(f"ERROR: {message}", file=sys.stderr)
                    return 1
                print(message, file=sys.stderr)
                continue

            if not isinstance(obj, dict):
                print(f"WARN: line {idx} is not an object, skipping", file=sys.stderr)
                continue
            rows.append(normalize_record(obj))

    rows.sort(key=lambda item: (item["timestamp"], item["id"], item["title"]))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=FIELDS)
        writer.writeheader()
        writer.writerows(rows)

    print(f"Wrote {len(rows)} rows to {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
