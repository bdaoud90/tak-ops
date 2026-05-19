# Buraq AI Integration (Proposed)

> **Status: PROPOSED / NOT IMPLEMENTED.** This document describes possible
> future integration points only. No code, services, dependencies, or
> infrastructure for this integration exist in the repository. Nothing here
> changes current system behavior.

## 1. Purpose

Buraq AI is being considered for **AI-enabled situational-awareness media
processing** to help **organize, classify, and review incident-related visual
information** (e.g., images and video associated with reported incidents).

The intent is **civilian-protection / media-triage**: making it faster for
human reviewers to organize evidence, tag scene/context, flag possible damage
or infrastructure impact, and prioritize what a person should look at next.
It is explicitly **not** identification, tracking, or targeting of
individuals.

## 2. Current System Summary

The current pipeline (see [data-flow.md](./data-flow.md)):

- **ACLED / static field documentation data** — `tooling/acled/acled_sync.py`
  fetches OAuth-authenticated, source-verified events; `tooling/notion/*`
  handles field/report records.
- **Refresh / normalization** — events are normalized to a stable schema;
  reports are normalized and converted to GeoJSON
  (`tooling/geo/csv_to_geojson.py`) and validated
  (`tooling/geo/validate_geojson.py`).
- **Normalized outputs** — `acled_latest.json`, `acled_latest.geojson`,
  `acled_latest_summary.json`, and versioned operational-layer GeoJSON.
- **Public incident tracker** — a **separate** public-facing PALSHIELD web
  component (not in this repo) consumes a compact `incidents.json`
  (see [schema/incidents-json.md](./schema/incidents-json.md)).
- **TAK / edge-node infrastructure** — TAK Server ingests layers and
  distributes the common operating picture to TAK clients; an edge node
  provides degraded/offline continuity. (Proprietary TAK binaries are a
  manual operator handoff and are **not vendored** here.)

Today there is **no media (image/video) pipeline** of any kind.

## 3. Possible Integration Points

All future / proposed:

- **Media intake pipeline (future).** A controlled ingest path for incident
  media (field upload / partner / manual), separate from public outputs.
- **Metadata extraction and normalization.** Capture time, device hints,
  declared location/precision, content hashes for deduplication.
- **Scene / object / context tagging.** Coarse scene classification
  (e.g., checkpoint, roadblock, structure damage, fire, crowd, vehicle,
  agricultural land) and object/context labels.
- **Damage / infrastructure-condition classification.** Tagging likely damage
  to structures, roads, agricultural land, or utilities.
- **Confidence scoring.** Per-label and per-indicator confidence values.
- **Human review queue.** AI output lands in a review queue; an operator
  approves/rejects/requests-more-context before any operational use.
- **Linking media-derived observations to incident records.** Associating
  reviewed observations with existing incident IDs (many-to-many).
- **Optional GeoJSON / CoT export.** For approved observations only, an
  optional situational-awareness layer export to feed TAK.

## 4. Proposed Data Contract

A proposed JSON shape for a future AI media-analysis **output** (illustrative;
field names and enums are open for discussion):

```json
{
  "media_id": "string",
  "source": "field_upload|partner|manual",
  "captured_at": "ISO-8601 timestamp or null",
  "location": {
    "lat": 0.0,
    "lng": 0.0,
    "precision": "exact|approximate|unknown"
  },
  "analysis": {
    "scene_type": ["checkpoint", "roadblock", "structure_damage", "fire", "crowd", "vehicle", "agricultural_land", "unknown"],
    "objects_detected": [
      {
        "label": "string",
        "confidence": 0.0
      }
    ],
    "risk_indicators": [
      {
        "type": "string",
        "confidence": 0.0,
        "notes": "string"
      }
    ]
  },
  "human_review": {
    "status": "pending|approved|rejected|needs_more_context",
    "reviewer_notes": ""
  },
  "linked_incident_ids": [],
  "redaction_required": true
}
```

Notes:

- `redaction_required` defaults to `true`; raw media is never published
  without explicit human review.
- `location.precision` must be honored downstream — `exact` locations may be
  withheld or coarsened in any public output (see §5).
- The contract separates **detection** (`objects_detected`) from
  **interpretation** (`risk_indicators`) deliberately; see Questions in §6.

## 5. Security Boundaries

These are hard constraints on any Buraq AI integration:

- **No biometric identification.**
- **No face recognition.**
- **No automated targeting** of people, vehicles, or locations.
- **No personal identity inference** (names, affiliation, "who is this").
- **No publication of raw sensitive media** without human review.
- **No precise sensitive locations in public outputs** unless explicitly
  approved; default to coarsened/withheld precision.
- **Human review is required** before any AI-derived output is used
  operationally or published.

## 6. Questions for Buraq AI

- What input formats do you support?
- Can you process still images, video, drone footage, body-camera footage,
  phone footage, or satellite imagery? Which of these are in scope?
- Can you return structured JSON (and conform to a contract like §4)?
- Can you run offline or on an edge node (air-gapped / intermittent comms)?
- What hardware is required (CPU/GPU/RAM, accelerators)?
- What languages / labels can your models handle?
- How do you handle Arabic / Hebrew / English text in images?
- Can you provide confidence scores per label and per indicator?
- Can you separate **detection** from **interpretation** in outputs?
- What is your false-positive / false-negative review workflow?
- Can sensitive media be processed locally **without cloud upload**?
- What logging is retained, for how long, and where?
- What data (if any) is used for model training, and can that be disabled?
