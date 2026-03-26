from __future__ import annotations

import csv
import json
import subprocess
from pathlib import Path


def test_validate_geojson(tmp_path: Path) -> None:
    sample = {
        "type": "FeatureCollection",
        "features": [
            {
                "type": "Feature",
                "geometry": {"type": "Point", "coordinates": [1.0, 2.0]},
                "properties": {"id": "abc"},
            }
        ],
    }
    geo = tmp_path / "sample.geojson"
    geo.write_text(json.dumps(sample), encoding="utf-8")

    result = subprocess.run(
        ["python3", "tooling/geo/validate_geojson.py", str(geo)],
        check=False,
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0
    assert "passed" in result.stdout.lower()


def test_csv_to_geojson_and_validate(tmp_path: Path) -> None:
    csv_path = tmp_path / "input.csv"
    with csv_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=["id", "title", "lat", "lon", "timestamp"])
        writer.writeheader()
        writer.writerow({"id": "1", "title": "a", "lat": "2.0", "lon": "1.0", "timestamp": "2026-01-01T00:00:00Z"})

    geo_path = tmp_path / "out.geojson"
    convert = subprocess.run(
        ["python3", "tooling/geo/csv_to_geojson.py", str(csv_path), str(geo_path)],
        check=False,
        capture_output=True,
        text=True,
    )
    assert convert.returncode == 0

    validate = subprocess.run(
        ["python3", "tooling/geo/validate_geojson.py", str(geo_path)],
        check=False,
        capture_output=True,
        text=True,
    )
    assert validate.returncode == 0
