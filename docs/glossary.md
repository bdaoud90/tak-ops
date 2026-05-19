# Glossary

Plain-language definitions of terms used across this repository. Aimed at new
maintainers and external partner reviewers.

| Term | Definition |
| --- | --- |
| **TAK** | *Tactical Awareness Kit* (a.k.a. Team Awareness Kit). A family of situational-awareness map clients (WinTAK, ATAK/CivTAK, iTAK) and a server (TAK Server) that share a common operating picture. In this project, TAK is the delivery surface operators use to view incident and operational layers. |
| **TAK Server** | The server component that authenticates clients, ingests data feeds/layers, and distributes the shared map picture to TAK clients. This repo provisions and operates the *infrastructure around* TAK Server; it does **not** vendor the proprietary TAK Server binaries. |
| **CoT** | *Cursor on Target*. The XML-based event/message schema TAK components use to exchange points, tracks, and events. A potential future export format for situational-awareness layers (see [buraq-ai-integration.md](./buraq-ai-integration.md)). |
| **ACLED** | *Armed Conflict Location & Event Data*. An external dataset/API of curated, source-verified conflict and political-violence events. This repo's `tooling/acled/` ingests ACLED via OAuth and normalizes it to a stable schema. |
| **GeoJSON** | Open standard for encoding geographic features as JSON. Convention here: WGS84 / EPSG:4326, coordinates ordered `[longitude, latitude]`. Produced by `tooling/geo/csv_to_geojson.py` and the ACLED sync. |
| **`incidents.json`** | The compact JSON payload consumed by the **public-facing PALSHIELD incident tracker** (a separate web component on the PALSHIELD website — *not* in this repo). It uses short field keys to keep the public payload small. Documented as a downstream contract in [schema/incidents-json.md](./schema/incidents-json.md). |
| **Incident** | A discrete, source-reported, ACLED-verifiable event (e.g., settler violence against a West Bank community) with a date, location, and descriptive attributes. |
| **Edge node** | A small local device (e.g., Raspberry Pi) that provides degraded/offline continuity when connectivity to the cloud TAK server is lost. Provisioned by `infra/ansible/playbooks/edge-node.yml`. |
| **Static layer** | A relatively stable reference layer (e.g., medical facilities, supply nodes, villages/AOPs) published as versioned GeoJSON, as opposed to fast-changing incident feeds. See [data/layer-schema.md](./data/layer-schema.md). |
| **Media triage** | Organizing, classifying, and prioritizing incident-related media (images/video) so human reviewers can assess it efficiently. The proposed scope for a Buraq AI integration — scene/context tagging and evidence organization, **not** identification or targeting. |
| **Partner integration** | A documented, proposed connection point where an external partner (e.g., Buraq AI) could add capability. In this repo, partner integration is **documentation-only** until explicitly approved and implemented. |
| **Operator** | The internal user who runs deployments, validates services, reviews data, and makes go/no-go decisions. Human review by an operator is required before any AI-derived output is used operationally. |
| **Pilot** | The current small-scale deployment posture. Defaults are pilot-friendly scaffolding and are expected to be hardened before large-scale production use. |
