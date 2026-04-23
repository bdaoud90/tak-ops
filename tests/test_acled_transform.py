from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from tooling.acled.transform import (
    events_to_feature_collection,
    normalize_event,
    to_geojson_feature,
)


def test_normalize_event_cleans_and_types_fields() -> None:
    raw = {
        "event_id_cnty": "  USA12345  ",
        "event_date": "2026-04-15",
        "event_type": " Battles ",
        "sub_event_type": None,
        "actor1": "Group A",
        "actor2": " ",
        "country": "USA",
        "admin1": "New York",
        "admin2": "Kings",
        "location": "Brooklyn",
        "fatalities": "2",
        "source": "ACLED",
        "notes": "  Example note ",
        "latitude": "40.6782",
        "longitude": "-73.9442",
    }

    normalized = normalize_event(raw)

    assert normalized["event_id"] == "USA12345"
    assert normalized["event_type"] == "Battles"
    assert normalized["sub_event_type"] == ""
    assert normalized["actor2"] == ""
    assert normalized["fatalities"] == 2
    assert normalized["latitude"] == 40.6782
    assert normalized["longitude"] == -73.9442


def test_to_geojson_feature_returns_none_without_coordinates() -> None:
    event = {"event_id": "USA12345", "latitude": None, "longitude": "-73.9442"}

    assert to_geojson_feature(event) is None


def test_events_to_feature_collection_filters_invalid_points() -> None:
    valid = normalize_event(
        {
            "event_id_cnty": "USA12345",
            "event_date": "2026-04-15",
            "event_type": "Battles",
            "latitude": "40.6782",
            "longitude": "-73.9442",
        }
    )
    invalid = normalize_event(
        {
            "event_id_cnty": "USA99999",
            "event_date": "2026-04-16",
            "event_type": "Protests",
            "latitude": "",
            "longitude": "-73.9000",
        }
    )

    collection = events_to_feature_collection([valid, invalid])

    assert collection["type"] == "FeatureCollection"
    assert len(collection["features"]) == 1
    assert collection["features"][0]["geometry"]["coordinates"] == [-73.9442, 40.6782]
    assert collection["features"][0]["properties"]["event_id"] == "USA12345"
