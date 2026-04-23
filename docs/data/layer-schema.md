# Operational Data Layer Schema

This document defines canonical layer schemas for operational geospatial ingestion and display workflows. It is intended to keep field definitions stable across mission planning, tactical updates, and automated ETL pipelines.

## Settler Attacks

| Item | Specification |
| --- | --- |
| Geometry type | `Point` (incident centroid) |
| Operator usage intent | **Strategic + Tactical**: strategic trend analysis and tactical deconfliction/response planning |

### Required fields

| Field | Type | Notes |
| --- | --- | --- |
| `attack_id` | `string` | Stable unique identifier (see format examples below) |
| `occurred_at` | `string` (ISO 8601 UTC) | Incident timestamp |
| `status` | `string` enum | Recommended: `reported`, `verified`, `closed` |
| `severity` | `integer` | Suggested scale `1-5` |
| `governorate` | `string` | Administrative area |
| `source_ref` | `string` | Report/source identifier |

### Optional fields

| Field | Type | Notes |
| --- | --- | --- |
| `affected_site` | `string` | Village/farm/road segment name |
| `casualties` | `integer` | Total injured/fatal count, if known |
| `damage_type` | `string` | E.g., property, agricultural, infrastructure |
| `summary` | `string` | Short narrative |
| `actor_group` | `string` | Suspected/confirmed actor grouping |
| `updated_at` | `string` (ISO 8601 UTC) | Last record update timestamp |

### ID and naming examples

- `ATT-QUSRA-20260422-01`
- `ATT-NABLUS-20260420-03`

---

## Medical Facilities

| Item | Specification |
| --- | --- |
| Geometry type | `Point` |
| Operator usage intent | **Strategic + Tactical**: strategic service coverage analysis and tactical casualty routing |

### Required fields

| Field | Type | Notes |
| --- | --- | --- |
| `facility_id` | `string` | Stable unique identifier |
| `facility_name` | `string` | Human-readable name |
| `facility_type` | `string` enum | Recommended: `clinic`, `hospital`, `field_station` |
| `status` | `string` enum | Recommended: `operational`, `degraded`, `offline` |
| `capacity_beds` | `integer` | Current bed capacity (or best estimate) |
| `last_verified_at` | `string` (ISO 8601 UTC) | Last operational verification |

### Optional fields

| Field | Type | Notes |
| --- | --- | --- |
| `trauma_capable` | `boolean` | Whether trauma procedures are supported |
| `ambulance_count` | `integer` | Available ambulances |
| `contact_phone` | `string` | Local phone/contact |
| `operating_hours` | `string` | E.g., `24/7`, `08:00-18:00` |
| `notes` | `string` | Routing constraints or alerts |

### ID and naming examples

- `MED-QUSRA-01`
- `MED-NABLUS-IBN-SINA-01`

---

## Supply Nodes

| Item | Specification |
| --- | --- |
| Geometry type | `Point` |
| Operator usage intent | **Strategic + Tactical**: strategic sustainment planning and tactical distribution execution |

### Required fields

| Field | Type | Notes |
| --- | --- | --- |
| `supply_id` | `string` | Stable unique identifier |
| `node_name` | `string` | Human-readable site name |
| `supply_type` | `string` enum | Recommended: `food`, `medical`, `fuel`, `mixed` |
| `status` | `string` enum | Recommended: `active`, `limited`, `inactive` |
| `stock_level` | `string` enum | Recommended: `high`, `medium`, `low`, `critical` |
| `last_updated_at` | `string` (ISO 8601 UTC) | Inventory/availability update time |

### Optional fields

| Field | Type | Notes |
| --- | --- | --- |
| `access_constraints` | `string` | Checkpoints, curfews, road risks |
| `distribution_window` | `string` | Delivery/collection timing |
| `owning_unit` | `string` | Unit/partner managing node |
| `cold_chain` | `boolean` | Indicates cold chain support |
| `notes` | `string` | Free-text operational notes |

### ID and naming examples

- `SUP-HUWARA-01`
- `SUP-NABLUS-WEST-02`

---

## Villages/AOPs

| Item | Specification |
| --- | --- |
| Geometry type | `Polygon` (preferred) or `Point` (fallback centroid) |
| Operator usage intent | **Strategic**: area-level planning, prioritization, and civil-context mapping; **Tactical**: local orientation |

### Required fields

| Field | Type | Notes |
| --- | --- | --- |
| `area_id` | `string` | Stable unique identifier |
| `area_name` | `string` | Village/AOP name |
| `area_type` | `string` enum | Recommended: `village`, `aop` |
| `status` | `string` enum | Recommended: `normal`, `watch`, `priority` |
| `population_est` | `integer` | Best available estimate |
| `last_reviewed_at` | `string` (ISO 8601 UTC) | Last review/update time |

### Optional fields

| Field | Type | Notes |
| --- | --- | --- |
| `admin_code` | `string` | Local administrative coding |
| `risk_level` | `string` enum | Recommended: `low`, `moderate`, `high` |
| `primary_access_route` | `string` | Main ingress/egress descriptor |
| `service_hub` | `string` | Nearest logistics/medical hub |
| `notes` | `string` | Additional contextual details |

### ID and naming examples

- `AOP-QUSRA-01`
- `VIL-BEITA-02`

---

## Observation Points

| Item | Specification |
| --- | --- |
| Geometry type | `Point` |
| Operator usage intent | **Primarily Tactical**: ISR positioning, line-of-sight monitoring, and short-horizon threat observation; secondary strategic patterning |

### Required fields

| Field | Type | Notes |
| --- | --- | --- |
| `op_id` | `string` | Stable unique identifier |
| `op_name` | `string` | Human-readable label |
| `status` | `string` enum | Recommended: `planned`, `active`, `inactive` |
| `coverage_azimuth` | `string` | Directional sector (e.g., `060-140`) |
| `visibility_rating` | `integer` | Suggested scale `1-5` |
| `last_checked_at` | `string` (ISO 8601 UTC) | Last status/field validation |

### Optional fields

| Field | Type | Notes |
| --- | --- | --- |
| `elevation_m` | `number` | Elevation in meters |
| `sensor_type` | `string` | Human observer, EO camera, thermal, etc. |
| `crew_size` | `integer` | Assigned personnel count |
| `handover_notes` | `string` | Shift/hand-off details |
| `notes` | `string` | Free-text operational notes |

### ID and naming examples

- `OBS-QUSRA-RIDGE-01`
- `OBS-HUWARA-JCT-02`

---

## Optional Routes

| Item | Specification |
| --- | --- |
| Geometry type | `LineString` |
| Operator usage intent | **Strategic + Tactical**: strategic contingency planning and tactical rerouting during disruption |

### Required fields

| Field | Type | Notes |
| --- | --- | --- |
| `route_id` | `string` | Stable unique identifier |
| `route_name` | `string` | Human-readable route label |
| `route_class` | `string` enum | Recommended: `primary_alternate`, `secondary_alternate`, `emergency_only` |
| `status` | `string` enum | Recommended: `open`, `restricted`, `closed` |
| `surface_type` | `string` enum | Recommended: `paved`, `gravel`, `dirt`, `mixed` |
| `last_assessed_at` | `string` (ISO 8601 UTC) | Last route assessment timestamp |

### Optional fields

| Field | Type | Notes |
| --- | --- | --- |
| `max_vehicle_class` | `string` | Vehicle compatibility category |
| `seasonal_risk` | `string` | Weather/season sensitivity |
| `travel_time_min` | `integer` | Expected travel time |
| `checkpoint_count` | `integer` | Expected control points en route |
| `notes` | `string` | Hazards or routing remarks |

### ID and naming examples

- `RTE-QUSRA-NABLUS-ALT1`
- `RTE-HUWARA-BEITA-EMR`

---

## Ingestion Conventions

### CRS expectation

- Default CRS: **WGS84 / EPSG:4326**.
- Coordinates should be ordered as `[longitude, latitude]` for GeoJSON compatibility.
- If ingesting projected CRS data, reproject to EPSG:4326 before publishing.

### Timestamp format

- Use UTC timestamps in ISO 8601 extended format: `YYYY-MM-DDTHH:MM:SSZ`.
- Example: `2026-04-23T14:05:00Z`.
- Use `*_at` suffix for datetime fields (e.g., `last_updated_at`).

### Status enum recommendations

- Keep layer-local enums explicit (as defined above).
- Avoid free-text status values in production pipelines.
- If a shared global status is required across layers, use: `active`, `degraded`, `inactive`, `unknown`.

### File naming and versioning

- File naming pattern: `<layer-key>_<aoi>_<yyyymmdd>_v<major>.<minor>.geojson`.
- Example: `medical_facilities_qusra_20260423_v1.2.geojson`.
- Increment `minor` for non-breaking updates (attribute edits, geometry corrections).
- Increment `major` for schema-breaking changes (field rename/removal/type changes).
