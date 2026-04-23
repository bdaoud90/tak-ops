# ACLED Sync Tooling

`acled_sync.py` performs OAuth-authenticated incremental fetches from an ACLED-compatible API, normalizes records, and writes JSON + GeoJSON outputs for downstream workflows.

## Outputs

The script writes these files into `ACLED_OUTPUT_DIR` (or `ACLED_STATE_DIR` when output dir is unset):

- `acled_latest.json`
- `acled_latest.geojson`
- `acled_latest_summary.json`

State is persisted in:

- `${ACLED_STATE_DIR}/acled_sync_state.json`

## Quick start

```bash
cd /workspace/tak-ops
python3 -m venv .venv
source .venv/bin/activate
pip install -r tooling/acled/requirements.txt
cp tooling/acled/.env.example tooling/acled/.env
set -a; source tooling/acled/.env; set +a
python3 tooling/acled/acled_sync.py --lookback-days 14
```

## Sync window behavior

- If `--lookback-days` is provided, it is used directly.
- Otherwise the script reads `last_successful_fetch_utc` from state and fetches from one hour before that timestamp.
- If state is missing/invalid, fallback is `ACLED_DEFAULT_LOOKBACK_DAYS`.
