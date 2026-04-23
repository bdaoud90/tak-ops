"""Pure ACLED normalization and GeoJSON conversion helpers."""

from __future__ import annotations

from typing import Any


def _clean_str(value: Any) -> str:
    if value is None:
        return ""
    return str(value).strip()


def _to_float(value: Any) -> float | None:
    if value in (None, ""):
        return None
    try:
        return float(value)
    except (TypeError, ValueError):
        return None


def normalize_event(record: dict[str, Any]) -> dict[str, Any]:
    """Normalize an ACLED event record into a stable, JSON-friendly shape."""
    normalized: dict[str, Any] = {
        "event_id": _clean_str(record.get("event_id_cnty") or record.get("event_id")),
        "event_date": _clean_str(record.get("event_date")),
        "event_type": _clean_str(record.get("event_type")),
        "sub_event_type": _clean_str(record.get("sub_event_type")),
        "actor1": _clean_str(record.get("actor1")),
        "actor2": _clean_str(record.get("actor2")),
        "country": _clean_str(record.get("country")),
        "admin1": _clean_str(record.get("admin1")),
        "admin2": _clean_str(record.get("admin2")),
        "location": _clean_str(record.get("location")),
        "fatalities": int(record.get("fatalities") or 0),
        "source": _clean_str(record.get("source")),
        "notes": _clean_str(record.get("notes")),
        "latitude": _to_float(record.get("latitude")),
        "longitude": _to_float(record.get("longitude")),
    }
    return normalized


def to_geojson_feature(event: dict[str, Any]) -> dict[str, Any] | None:
    """Convert a normalized ACLED event into a GeoJSON feature."""
    lat = _to_float(event.get("latitude"))
    lon = _to_float(event.get("longitude"))
    if lat is None or lon is None:
        return None

    props = {k: v for k, v in event.items() if k not in {"latitude", "longitude"}}
    return {
        "type": "Feature",
        "geometry": {"type": "Point", "coordinates": [lon, lat]},
        "properties": props,
    }


def events_to_feature_collection(events: list[dict[str, Any]]) -> dict[str, Any]:
    """Convert normalized events into a GeoJSON FeatureCollection."""
    features: list[dict[str, Any]] = []
    for event in events:
        feature = to_geojson_feature(event)
        if feature is not None:
            features.append(feature)

    return {"type": "FeatureCollection", "features": features}
