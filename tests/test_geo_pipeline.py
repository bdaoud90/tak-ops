from __future__ import annotations

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
