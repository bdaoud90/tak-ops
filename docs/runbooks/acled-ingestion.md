# ACLED Ingestion Runbook

## Purpose

This runbook covers operation of `tooling/acled/acled_sync.py`, which ingests ACLED events using OAuth, normalizes them into a stable internal schema, writes latest outputs, and stores rolling-sync state.

## Files

- Sync script: `tooling/acled/acled_sync.py`
- Env template: `tooling/acled/.env.example`
- Optional dependency pin: `tooling/acled/requirements.txt`
- Optional reference: `tooling/acled/README.md`

## Prerequisites

1. Python 3.10+
2. Network access to OAuth token endpoint and ACLED events endpoint
3. Valid credentials for:
   - `ACLED_CLIENT_ID`
   - `ACLED_CLIENT_SECRET`

## Configure

```bash
cp tooling/acled/.env.example tooling/acled/.env
# edit tooling/acled/.env with real endpoint URLs + credentials
```

Load environment variables:

```bash
set -a
source tooling/acled/.env
set +a
```

## Execution

### One-off lookback run

```bash
python3 tooling/acled/acled_sync.py --lookback-days 14
```

### Incremental run from state

```bash
python3 tooling/acled/acled_sync.py
```

Incremental mode behavior:

- Uses `${ACLED_STATE_DIR}/acled_sync_state.json` when present.
- Reads `last_successful_fetch_utc` and applies a 1-hour overlap window.
- If state is missing or invalid, defaults to `ACLED_DEFAULT_LOOKBACK_DAYS`.

## Outputs

Written to `ACLED_OUTPUT_DIR` (defaults to `ACLED_STATE_DIR`):

- `acled_latest.json` — normalized event array
- `acled_latest.geojson` — GeoJSON FeatureCollection (events with coordinates)
- `acled_latest_summary.json` — counts, fatalities, event type/country groupings

State file in `ACLED_STATE_DIR`:

- `acled_sync_state.json`

## Normalized schema

Each event in `acled_latest.json` includes:

- `source`
- `event_id`
- `event_date`
- `country`, `region`, `admin1`, `admin2`, `location`
- `event_type`, `sub_event_type`, `disorder_type`
- `actor1`, `actor2`
- `fatalities`
- `latitude`, `longitude`
- `notes`
- `raw` (original API record)

## Operator troubleshooting

- Increase logs: `ACLED_LOG_LEVEL=DEBUG`
- Token failures (`401`/`403`): verify OAuth endpoint, client ID/secret, scope/audience
- Empty result sets:
  - Validate date params (`ACLED_DATE_FROM_PARAM`, `ACLED_DATE_TO_PARAM`)
  - Run a wider window with `--lookback-days`
- Pagination truncation warning:
  - If logs show `Reached ACLED_MAX_PAGES`, increase `ACLED_MAX_PAGES` and rerun
- TLS issues in lab environments:
  - temporary only: `ACLED_VERIFY_TLS=false`

## Suggested scheduling

Use cron or systemd timer every 30–60 minutes in incremental mode.

Example cron entry:

```cron
*/30 * * * * cd /workspace/tak-ops && set -a && . tooling/acled/.env && set +a && python3 tooling/acled/acled_sync.py >> tooling/acled/state/acled_sync.log 2>&1
```
