# 01 · System Overview

`tak-ops` is the **infrastructure + data-ingestion backend** for the PALSHIELD
situational-awareness TAK environment.

## What it contains

- **Infrastructure-as-Code** — Terraform (DigitalOcean) and Ansible
  (Ubuntu 24.04 hardening, reverse proxy/TLS, backup, edge node).
- **Operator tooling** — shell scripts for env setup, config validation,
  smoke tests, backup/restore, sanitized operator-bundle packaging.
- **Data tooling** — Python for ACLED ingestion/normalization, CSV→GeoJSON,
  GeoJSON validation, and Notion report export/normalization.
- **Docs** — architecture, runbooks, SOPs, threat model, schemas.

## What it is not

- Not the public incident tracker UI — that is a **separate** PALSHIELD web
  component fed by this pipeline. No front-end / GitHub Pages / iframe here.
- Not a redistribution of proprietary TAK Server binaries — those are a
  documented manual operator handoff.

## Roles served

- **Operator** — runs deployments, validates services, reviews data.
- **Developer/maintainer** — extends tooling and IaC, keeps CI green.
- **External partner reviewer** — assesses safe integration points
  (start at [partner-review.md](../partner-review.md)).

See also: [02 · Data Flow](./02-data-flow.md),
[architecture.md](../architecture.md), [glossary.md](../glossary.md).
