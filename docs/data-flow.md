# Data Flow

How situational-awareness data moves from upstream sources, through this
repository's ingestion/normalization tooling, into the TAK server/map and the
separate public incident tracker, and where a **proposed** Buraq AI
media-analysis path would attach.

> Everything in the dashed/"proposed" path is **not implemented**. It is
> documentation of a possible future integration only.

```mermaid
flowchart TD
    subgraph Sources["Upstream data sources"]
        ACLED["ACLED API\n(OAuth, verified events)"]
        NOTION["Notion / field reports\n(NDJSON / CSV)"]
        FUTURE["Other future layers\n(medical, supply, routes, ...)"]
    end

    subgraph Ingest["tak-ops ingestion + normalization"]
        SYNC["tooling/acled/acled_sync.py\nfetch → normalize → write"]
        NORM["tooling/notion/*\nexport / normalize"]
        CSV["tooling/geo/csv_to_geojson.py"]
        VAL["tooling/geo/validate_geojson.py\nschema validation"]
    end

    subgraph Artifacts["Normalized artifacts"]
        JSON["acled_latest.json\nacled_latest_summary.json"]
        GEO["GeoJSON FeatureCollections\nWGS84 / [lon, lat]"]
    end

    TAK["TAK Server\n(ingest + auth + distribute)"]
    CLIENTS["TAK clients\nWinTAK / CivTAK / iTAK"]
    TRACKER["Public PALSHIELD incident tracker\n(separate web component — not in this repo)"]
    OPER["Operator review\n(go / no-go, verification)"]

    ACLED --> SYNC --> JSON
    SYNC --> GEO
    NOTION --> NORM --> CSV --> GEO
    FUTURE --> CSV
    GEO --> VAL --> TAK
    JSON --> TAK
    TAK --> CLIENTS
    GEO --> TRACKER
    JSON --> TRACKER
    TAK --> OPER
    TRACKER --> OPER

    subgraph Proposed["Proposed Buraq AI media path (NOT implemented)"]
        MEDIA["Incident media intake\n(field upload / partner / manual)"]
        AI["Buraq AI media analysis\nscene/context tagging,\ndamage classification,\nconfidence scoring"]
        QUEUE["Human review queue"]
    end

    MEDIA -.-> AI -.-> QUEUE -.-> OPER
    OPER -.->|approved, linked to incident| TAK
    AI -.->|structured JSON\n(proposed contract)| QUEUE
```

## Narrative

1. **Sources.** ACLED provides OAuth-authenticated, source-verified conflict
   events. Field/Notion reports arrive as NDJSON/CSV. Additional reference
   layers (medical facilities, supply nodes, routes, etc.) are planned.
2. **Ingestion/normalization (this repo).** `acled_sync.py` authenticates,
   pages the ACLED API for a resolved time window, normalizes rows onto a
   stable schema, and writes JSON + GeoJSON + a summary. The Notion tooling
   exports/normalizes reports; `csv_to_geojson.py` converts them to GeoJSON;
   `validate_geojson.py` enforces the GeoJSON contract.
3. **Distribution.** Normalized artifacts feed the TAK Server, which
   authenticates clients and distributes the common operating picture to TAK
   clients. The same normalized data also feeds the **separate** public
   PALSHIELD incident tracker.
4. **Operator review.** Operators verify and make go/no-go decisions. Human
   review is the control point before anything is treated as operational.
5. **Proposed AI path (future, not built).** Incident media could be sent to
   Buraq AI for scene/context tagging and damage classification, returning a
   structured JSON contract into a human-review queue. Only operator-approved,
   reviewed output would be linked back to incident records / TAK layers. No
   biometric identification, face recognition, or targeting — see
   [buraq-ai-integration.md §5](./buraq-ai-integration.md#5-security-boundaries).
