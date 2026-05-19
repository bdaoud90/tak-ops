# Documentation Index

This directory holds architecture, operations, schema, and partner-review
documentation for **`tak-ops`** — the infrastructure and data-ingestion
backend for the PALSHIELD situational-awareness TAK environment.

> **New here?** Start with the [Partner Review guide](./partner-review.md).

## Partner-facing (read these first)

| Doc | Purpose |
| --- | --- |
| [partner-review.md](./partner-review.md) | What an external reviewer should read, in order |
| [data-flow.md](./data-flow.md) | End-to-end data flow diagram (sources → TAK → review) |
| [schema/incidents-json.md](./schema/incidents-json.md) | Data schemas: in-repo + public-tracker contract |
| [buraq-ai-integration.md](./buraq-ai-integration.md) | Proposed AI media-triage integration points |
| [security-and-data-handling.md](./security-and-data-handling.md) | What must not be committed / must be redacted |
| [glossary.md](./glossary.md) | TAK, CoT, ACLED, GeoJSON, edge node, and more |

## Architecture & design

- [architecture.md](./architecture.md) — components, design goals, trust boundaries
- [architecture/tak-service-map.md](./architecture/tak-service-map.md) — TAK service mapping
- [threat-model.md](./threat-model.md) — risks and mitigations
- [data/layer-schema.md](./data/layer-schema.md) — canonical operational layer schemas

## Runbooks (operations)

- [runbooks/quickstart-download-install-deploy.md](./runbooks/quickstart-download-install-deploy.md)
- [runbooks/first-deploy.md](./runbooks/first-deploy.md)
- [runbooks/deployment.md](./runbooks/deployment.md) — partner-safe deployment overview
- [runbooks/local-development.md](./runbooks/local-development.md) — partner-safe local-dev overview
- [runbooks/acled-ingestion.md](./runbooks/acled-ingestion.md)
- [runbooks/smoke-test.md](./runbooks/smoke-test.md)
- [runbooks/incident-recovery.md](./runbooks/incident-recovery.md)
- [runbooks/tak-demo-mvp.md](./runbooks/tak-demo-mvp.md)

## SOPs & checklists

- [deployment-plan.md](./deployment-plan.md)
- [backup-restore.md](./backup-restore.md) · [backup-verification-checklist.md](./backup-verification-checklist.md)
- [edge-node.md](./edge-node.md) · [degraded-comms.md](./degraded-comms.md) · [outage-mode-sop.md](./outage-mode-sop.md)
- [pilot-rollout-checklist.md](./pilot-rollout-checklist.md) · [known-issues.md](./known-issues.md)
- [notion-qgis-pipeline.md](./notion-qgis-pipeline.md)
- [project-management/hardening-execution-checklist.md](./project-management/hardening-execution-checklist.md)

## Internal wiki (versioned)

Short, GitHub-wiki-style pages under [wiki/](./wiki/):

1. [System Overview](./wiki/01-system-overview.md)
2. [Data Flow](./wiki/02-data-flow.md)
3. [Local Development](./wiki/03-local-development.md)
4. [Deployment & Operations](./wiki/04-deployment-and-operations.md)
5. [Buraq AI Partner Review](./wiki/05-buraq-ai-partner-review.md)
6. [Security & Redaction Rules](./wiki/06-security-redaction-rules.md)
7. [Open Questions](./wiki/07-open-questions.md)

## Backlog

Phased backlog items (provisioning → hardening → tooling → CI) live under
[backlog/](./backlog/).
