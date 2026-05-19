# 02 · Data Flow

Summary (full diagram in [data-flow.md](../data-flow.md)):

1. **Sources** — ACLED API (OAuth, verified events), Notion/field reports
   (NDJSON/CSV), and future reference layers.
2. **Ingestion/normalization (this repo)** — `tooling/acled/acled_sync.py`
   (fetch → normalize → write), `tooling/notion/*`, `tooling/geo/*`.
3. **Artifacts** — `acled_latest.json`, `acled_latest.geojson`,
   `acled_latest_summary.json`, and versioned operational-layer GeoJSON
   (WGS84, `[lon, lat]`).
4. **Distribution** — TAK Server ingests and distributes the common operating
   picture to TAK clients; the same normalized data feeds the **separate**
   public incident tracker.
5. **Operator review** — go/no-go and verification; the control point before
   anything is operational.
6. **Proposed Buraq AI media path** — *not implemented*; would attach at a
   human-review queue, never bypassing operator review. See
   [buraq-ai-integration.md](../buraq-ai-integration.md).

See also: [schema/incidents-json.md](../schema/incidents-json.md),
[data/layer-schema.md](../data/layer-schema.md).
