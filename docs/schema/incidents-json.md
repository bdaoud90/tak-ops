# Data Schemas: Incidents & Related Layers

This document describes the data schemas relevant to incident reporting:

1. The **public incident-tracker contract** (`incidents.json`) — a downstream
   public payload consumed by a **separate** PALSHIELD web component.
2. The **actual in-repo schemas** produced by this repository's tooling.
3. A **proposed, not-implemented** media-analysis extension.

> Important: `incidents.json` itself is **not stored in this repository**. The
> public-facing incident tracker is a separate web component on the PALSHIELD
> website. This page documents the contract so partners and maintainers
> understand the downstream shape that this repo's pipeline ultimately feeds.

---

## 1. Public incident-tracker contract (`incidents.json`)

The public tracker visualizes source-reported, ACLED-verifiable incidents
(e.g., settler violence against West Bank communities). To keep the
public payload small for a browser-based map, it uses **compact field keys**.

### Top-level shape

A JSON document with a metadata header and an array of incident records, e.g.:

```json
{
  "updated": "ISO-8601 timestamp",
  "incidents": [ { "d": "...", "lat": 0.0, "lng": 0.0, "g": "...", "l": "...", "p": 0, "f": 0, "n": "...", "s": 0, "vt": [0] } ]
}
```

Required top-level keys (recommended): `updated` (or equivalent generation
timestamp) and `incidents` (array). Lookup tables for indexed fields
(`p`, `s`, `vt`) are published alongside the records (e.g., a `meta` /
`legends` object or sibling arrays) so indexes resolve to labels.

### Per-incident compact fields

| Key | Meaning | Type | Notes |
| --- | --- | --- | --- |
| `d` | Date | string | Incident date (ISO-8601 `YYYY-MM-DD` recommended) |
| `lat` | Latitude | number | WGS84 |
| `lng` | Longitude | number | WGS84 (note: public web convention uses `lat`/`lng`) |
| `g` | Governorate | string | Administrative area |
| `l` | Locality / location | string | Town/village/site label |
| `p` | Perpetrator category | integer | **Index** into a perpetrator-category lookup array |
| `f` | Fatalities | integer | Count (0 if none) |
| `n` | Notes | string | Short public-safe narrative |
| `s` | Source | integer | **Index** into a sources lookup array |
| `vt` | Violation type(s) | array of integers | **Indexes** into a violation-type lookup array (omit/empty if not present) |

### Why compact fields?

- The payload is fetched by a public, browser-based visualization; short keys
  meaningfully reduce transfer size across many records.
- Indexed fields (`p`, `s`, `vt`) deduplicate repeated long strings
  (categories, source names, violation labels) into small integers plus one
  shared lookup table.

### What must / must not go into public `incidents.json`

**May include:** publicly reportable, source-verified attributes; coarsened
location appropriate for public release; short public-safe notes.

**Must NOT include:** exact sensitive coordinates unless explicitly approved;
source/field identities; internal-only attributes; raw media; operational
procedures; anything in
[security-and-data-handling.md](../security-and-data-handling.md) "Do not
commit / Redact" lists. Treat location precision as deliberate — default to
coarsened precision for sensitive sites.

---

## 2. Actual in-repo schemas

These are produced by tooling in this repository and use **full, explicit
field names** (not compact keys).

### 2a. ACLED normalized event — `tooling/acled/`

`acled_sync.py` writes `acled_latest.json` (array). Each event:

`source`, `event_id`, `event_date`, `country`, `region`, `admin1`,
`admin2`, `location`, `event_type`, `sub_event_type`, `disorder_type`,
`actor1`, `actor2`, `fatalities`, `latitude`, `longitude`, `notes`,
`raw` (original API record). Also emitted: `acled_latest.geojson`
(FeatureCollection, `raw` excluded) and `acled_latest_summary.json`
(aggregate counts). See
[runbooks/acled-ingestion.md](../runbooks/acled-ingestion.md) and
`tooling/acled/transform.py`.

### 2b. Operational layer schemas

Canonical schemas for Settler Attacks, Medical Facilities, Supply Nodes,
Villages/AOPs, Observation Points, and Routes are defined in
[`docs/data/layer-schema.md`](../data/layer-schema.md). Conventions: WGS84 /
EPSG:4326, coordinates `[longitude, latitude]`, ISO-8601 UTC timestamps with
`*_at` suffix.

### 2c. Notion / report CSV — `tooling/notion/`

Report records flow through `export_reports.py` / `normalize_reports.py` with
fields: `id` (required), `title`, `lat`, `lon`, `timestamp`. These are then
converted to GeoJSON by `tooling/geo/csv_to_geojson.py` and validated by
`tooling/geo/validate_geojson.py`.

---

## 3. Future media-analysis extension (proposed — NOT implemented)

If a Buraq AI media-triage integration is approved, an incident record could
optionally carry a reference to reviewed media-analysis output. **This is not
implemented and must not be added without explicit approval.** The proposed
output contract lives in
[`buraq-ai-integration.md` §4](../buraq-ai-integration.md#4-proposed-data-contract)
(`media_id`, `analysis`, `human_review`, `linked_incident_ids`,
`redaction_required`, ...). Only operator-approved, redaction-cleared output
would ever be associated with a public incident, and never raw media.
