#!/usr/bin/env python3
"""Fetch, normalize, and persist ACLED events for downstream ops workflows."""

from __future__ import annotations

import argparse
import json
import logging
import os
import sys
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any

import requests

LOGGER = logging.getLogger("acled_sync")
STATE_FILE = "acled_sync_state.json"


@dataclass(frozen=True)
class Config:
    token_url: str
    events_url: str
    client_id: str
    client_secret: str
    audience: str | None
    scope: str | None
    verify_tls: bool
    timeout_seconds: int
    page_size: int
    max_pages: int
    output_dir: Path
    state_dir: Path
    date_from_param: str
    date_to_param: str


@dataclass(frozen=True)
class FetchWindow:
    start: datetime
    end: datetime


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--lookback-days",
        type=int,
        default=None,
        help="Lookback window in days. If omitted, uses state-driven incremental sync.",
    )
    parser.add_argument(
        "--log-level",
        default=os.getenv("ACLED_LOG_LEVEL", "INFO"),
        help="Logging level (default: ACLED_LOG_LEVEL or INFO).",
    )
    return parser.parse_args()


def configure_logging(level: str) -> None:
    logging.basicConfig(
        level=getattr(logging, level.upper(), logging.INFO),
        format="%(asctime)s %(levelname)s %(name)s: %(message)s",
    )


def require_env(name: str) -> str:
    value = os.getenv(name, "").strip()
    if not value:
        raise ValueError(f"Required environment variable missing: {name}")
    return value


def load_config() -> Config:
    state_dir = Path(os.getenv("ACLED_STATE_DIR", "tooling/acled/state")).resolve()
    output_dir = Path(os.getenv("ACLED_OUTPUT_DIR", str(state_dir))).resolve()
    return Config(
        token_url=require_env("ACLED_TOKEN_URL"),
        events_url=require_env("ACLED_EVENTS_URL"),
        client_id=require_env("ACLED_CLIENT_ID"),
        client_secret=require_env("ACLED_CLIENT_SECRET"),
        audience=os.getenv("ACLED_AUDIENCE", "").strip() or None,
        scope=os.getenv("ACLED_SCOPE", "").strip() or None,
        verify_tls=os.getenv("ACLED_VERIFY_TLS", "true").lower() != "false",
        timeout_seconds=int(os.getenv("ACLED_TIMEOUT_SECONDS", "30")),
        page_size=int(os.getenv("ACLED_PAGE_SIZE", "500")),
        max_pages=int(os.getenv("ACLED_MAX_PAGES", "200")),
        output_dir=output_dir,
        state_dir=state_dir,
        date_from_param=os.getenv("ACLED_DATE_FROM_PARAM", "event_date__gte"),
        date_to_param=os.getenv("ACLED_DATE_TO_PARAM", "event_date__lte"),
    )


def load_state(state_dir: Path) -> dict[str, Any]:
    path = state_dir / STATE_FILE
    if not path.exists():
        LOGGER.info("State file missing at %s; starting with clean state", path)
        return {}

    try:
        raw = json.loads(path.read_text(encoding="utf-8"))
        if not isinstance(raw, dict):
            LOGGER.warning("State file malformed (not object); ignoring %s", path)
            return {}
        return raw
    except json.JSONDecodeError:
        LOGGER.exception("State file has invalid JSON; ignoring %s", path)
        return {}


def save_state(state_dir: Path, state: dict[str, Any]) -> None:
    state_dir.mkdir(parents=True, exist_ok=True)
    path = state_dir / STATE_FILE
    path.write_text(json.dumps(state, indent=2, sort_keys=True), encoding="utf-8")
    LOGGER.info("Saved state to %s", path)


def oauth_token(config: Config) -> str:
    payload: dict[str, str] = {
        "grant_type": "client_credentials",
        "client_id": config.client_id,
        "client_secret": config.client_secret,
    }
    if config.audience:
        payload["audience"] = config.audience
    if config.scope:
        payload["scope"] = config.scope

    LOGGER.info("Requesting OAuth token from %s", config.token_url)
    response = requests.post(
        config.token_url,
        data=payload,
        timeout=config.timeout_seconds,
        verify=config.verify_tls,
    )
    if response.status_code >= 400:
        LOGGER.error("Token request failed (%s): %s", response.status_code, response.text[:500])
        response.raise_for_status()

    body = response.json()
    token = body.get("access_token")
    if not token:
        raise RuntimeError("OAuth response missing access_token")
    return str(token)


def resolve_window(now_utc: datetime, state: dict[str, Any], lookback_days: int | None) -> FetchWindow:
    if lookback_days is not None:
        start = now_utc - timedelta(days=max(1, lookback_days))
        LOGGER.info("Using explicit lookback window: %s days", lookback_days)
        return FetchWindow(start=start, end=now_utc)

    previous = state.get("last_successful_fetch_utc")
    if previous:
        try:
            previous_dt = datetime.fromisoformat(str(previous).replace("Z", "+00:00"))
            start = previous_dt - timedelta(hours=1)
            LOGGER.info("Using incremental window from prior state: %s", previous_dt.isoformat())
            return FetchWindow(start=start, end=now_utc)
        except ValueError:
            LOGGER.warning("State has invalid timestamp; falling back to default lookback")

    default_days = int(os.getenv("ACLED_DEFAULT_LOOKBACK_DAYS", "7"))
    start = now_utc - timedelta(days=max(1, default_days))
    LOGGER.info("Using default lookback window: %s days", default_days)
    return FetchWindow(start=start, end=now_utc)


def parse_records(payload: Any) -> list[dict[str, Any]]:
    if isinstance(payload, dict):
        for key in ("data", "results", "events"):
            value = payload.get(key)
            if isinstance(value, list):
                return [item for item in value if isinstance(item, dict)]
    if isinstance(payload, list):
        return [item for item in payload if isinstance(item, dict)]
    return []


def fetch(config: Config, token: str, window: FetchWindow) -> list[dict[str, Any]]:
    headers = {"Authorization": f"Bearer {token}", "Accept": "application/json"}
    page = 1
    all_rows: list[dict[str, Any]] = []

    while page <= config.max_pages:
        params = {
            config.date_from_param: window.start.date().isoformat(),
            config.date_to_param: window.end.date().isoformat(),
            "limit": config.page_size,
            "page": page,
        }
        LOGGER.info("Fetching ACLED page=%s with params=%s", page, params)
        response = requests.get(
            config.events_url,
            headers=headers,
            params=params,
            timeout=config.timeout_seconds,
            verify=config.verify_tls,
        )

        if response.status_code >= 400:
            LOGGER.error("Fetch failed (%s): %s", response.status_code, response.text[:500])
            response.raise_for_status()

        payload = response.json()
        rows = parse_records(payload)
        if not rows:
            LOGGER.info("No rows returned on page=%s; ending pagination", page)
            break

        all_rows.extend(rows)
        LOGGER.info("Fetched %s rows on page=%s (running total=%s)", len(rows), page, len(all_rows))
        if len(rows) < config.page_size:
            break
        page += 1

    if page > config.max_pages:
        LOGGER.warning("Reached ACLED_MAX_PAGES=%s; results may be incomplete", config.max_pages)

    return all_rows


def to_float(value: Any) -> float | None:
    try:
        if value in (None, ""):
            return None
        return float(value)
    except (TypeError, ValueError):
        return None


def to_int(value: Any) -> int | None:
    try:
        if value in (None, ""):
            return None
        return int(value)
    except (TypeError, ValueError):
        return None


def normalize(records: list[dict[str, Any]]) -> list[dict[str, Any]]:
    normalized: list[dict[str, Any]] = []
    for row in records:
        event_id = row.get("event_id_cnty") or row.get("event_id_no_cnty") or row.get("event_id")
        if not event_id:
            LOGGER.warning("Skipping row with missing event id")
            continue

        lat = to_float(row.get("latitude") or row.get("lat"))
        lon = to_float(row.get("longitude") or row.get("lon") or row.get("lng"))

        normalized.append(
            {
                "source": "acled",
                "event_id": str(event_id),
                "event_date": row.get("event_date"),
                "country": row.get("country"),
                "region": row.get("region"),
                "admin1": row.get("admin1"),
                "admin2": row.get("admin2"),
                "location": row.get("location"),
                "event_type": row.get("event_type"),
                "sub_event_type": row.get("sub_event_type"),
                "disorder_type": row.get("disorder_type"),
                "actor1": row.get("actor1"),
                "actor2": row.get("actor2"),
                "fatalities": to_int(row.get("fatalities")),
                "latitude": lat,
                "longitude": lon,
                "notes": row.get("notes"),
                "raw": row,
            }
        )

    normalized.sort(key=lambda item: (str(item.get("event_date") or ""), item["event_id"]))
    LOGGER.info("Normalized %s events", len(normalized))
    return normalized


def to_geojson(events: list[dict[str, Any]]) -> dict[str, Any]:
    features: list[dict[str, Any]] = []
    for event in events:
        lon = event.get("longitude")
        lat = event.get("latitude")
        if lon is None or lat is None:
            continue

        props = {k: v for k, v in event.items() if k not in {"longitude", "latitude", "raw"}}
        features.append(
            {
                "type": "Feature",
                "geometry": {"type": "Point", "coordinates": [lon, lat]},
                "properties": props,
            }
        )

    return {"type": "FeatureCollection", "features": features}


def write_summary(events: list[dict[str, Any]]) -> dict[str, Any]:
    summary: dict[str, Any] = {
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "total_events": len(events),
        "events_with_coordinates": sum(
            1 for e in events if e.get("longitude") is not None and e.get("latitude") is not None
        ),
        "total_fatalities": sum((e.get("fatalities") or 0) for e in events),
        "by_event_type": {},
        "by_country": {},
    }

    by_type: dict[str, int] = {}
    by_country: dict[str, int] = {}
    for event in events:
        event_type = str(event.get("event_type") or "unknown")
        country = str(event.get("country") or "unknown")
        by_type[event_type] = by_type.get(event_type, 0) + 1
        by_country[country] = by_country.get(country, 0) + 1

    summary["by_event_type"] = dict(sorted(by_type.items()))
    summary["by_country"] = dict(sorted(by_country.items()))
    return summary


def write_outputs(config: Config, events: list[dict[str, Any]]) -> None:
    config.output_dir.mkdir(parents=True, exist_ok=True)
    latest_json = config.output_dir / "acled_latest.json"
    latest_geojson = config.output_dir / "acled_latest.geojson"
    summary_json = config.output_dir / "acled_latest_summary.json"

    latest_json.write_text(json.dumps(events, indent=2), encoding="utf-8")
    latest_geojson.write_text(json.dumps(to_geojson(events), indent=2), encoding="utf-8")
    summary_json.write_text(json.dumps(write_summary(events), indent=2), encoding="utf-8")
    LOGGER.info("Wrote outputs: %s, %s, %s", latest_json, latest_geojson, summary_json)


def main() -> int:
    args = parse_args()
    configure_logging(args.log_level)

    try:
        config = load_config()
    except Exception as exc:
        LOGGER.error("Invalid configuration: %s", exc)
        return 1

    state = load_state(config.state_dir)
    now_utc = datetime.now(timezone.utc)
    window = resolve_window(now_utc=now_utc, state=state, lookback_days=args.lookback_days)

    try:
        token = oauth_token(config)
        records = fetch(config, token, window)
        events = normalize(records)
        write_outputs(config, events)

        state["last_successful_fetch_utc"] = now_utc.isoformat()
        state["last_run_total_records"] = len(records)
        state["last_run_total_events"] = len(events)
        save_state(config.state_dir, state)
    except requests.RequestException:
        LOGGER.exception("ACLED request failed")
        return 2
    except Exception:
        LOGGER.exception("ACLED sync failed")
        return 3

    LOGGER.info("ACLED sync complete. events=%s", len(events))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
