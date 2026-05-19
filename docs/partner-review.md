# Partner Review Guide

**Audience:** an external technical partner (Buraq AI) reviewing this codebase
to understand the system and identify *safe* integration points for
AI-enabled situational-awareness media/image processing.

This page is a **partner-safe overview**. Nothing here contains secrets,
credentials, private coordinates, server identities, or field procedures.

## What this repository is (and is not)

`tak-ops` is the **infrastructure + data-ingestion backend** for the PALSHIELD
situational-awareness TAK environment. It contains:

- Infrastructure-as-Code: Terraform (DigitalOcean) and Ansible (Ubuntu 24.04
  hardening, reverse proxy/TLS scaffolding, backup, edge node).
- Operator shell tooling: env setup, config validation, smoke tests,
  backup/restore, sanitized operator-bundle packaging.
- Python data tooling: ACLED ingestion + normalization, CSV→GeoJSON
  conversion, GeoJSON validation, Notion report export/normalization.
- Documentation: architecture, runbooks, SOPs, threat model, schemas.

It is **not**:

- The public incident tracker UI. That **public-facing data-visualization
  tool lives separately on the PALSHIELD website** and is fed by this
  pipeline; there is no front-end (`index.html`/JS), GitHub Pages site, or
  WordPress embed in this repository.
- A redistribution of proprietary/restricted TAK Server binaries (these are a
  documented manual operator handoff, not vendored here).

## Recommended reading order

1. [`README.md`](../README.md) — repository map, current state, what works,
   manual steps, known gaps, validation commands, partner integration points.
2. [`docs/partner-review.md`](./partner-review.md) — this page.
3. [`docs/data-flow.md`](./data-flow.md) — how data moves from sources to TAK
   clients and where a future AI media path would attach.
4. [`docs/schema/incidents-json.md`](./schema/incidents-json.md) — the data
   schemas: the real in-repo schemas and the public-tracker contract.
5. [`docs/buraq-ai-integration.md`](./buraq-ai-integration.md) — proposed
   integration points, the proposed data contract, security boundaries, and
   open questions for Buraq AI.
6. [`docs/security-and-data-handling.md`](./security-and-data-handling.md) —
   what must never be in the repo and what must be redacted before sharing.
7. Source files — only after the above:
   - `tooling/acled/` — ACLED OAuth sync + normalization
   - `tooling/geo/` — CSV→GeoJSON + GeoJSON validation
   - `tooling/notion/` — report export/normalization
   - `infra/` — Terraform + Ansible (no secrets; examples only)

## What we would like from this review

- Confirmation of which integration points in
  [`buraq-ai-integration.md`](./buraq-ai-integration.md) are feasible.
- Answers to the **Questions for Buraq AI** section of that document.
- Feedback on the **proposed data contract** for AI media-analysis output.
- Any concerns about the **security boundaries** we have specified.

## Out of scope (hard boundaries)

No biometric identification, face recognition, individual tracking,
targeting, or weaponization. The integration intent is civilian-protection /
media-triage only: scene/context classification, incident-media metadata,
evidence organization, damage/infrastructure tagging, and optional
human-review workflows. See
[`buraq-ai-integration.md` §5](./buraq-ai-integration.md#5-security-boundaries).
