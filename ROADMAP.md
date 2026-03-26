# ROADMAP

## Phase 1: Baseline deployment
- Finalize pilot `dev` + `prod` infrastructure variables.
- Validate repeatable Terraform/Ansible workflow.
- Document manual TAK installation handoff with operator evidence.

## Phase 2: Edge node
- Harden edge-node role for Raspberry Pi variants.
- Add repeatable sync queue handling docs/scripts (non-proprietary scope).
- Validate outage drills with field operators.

## Phase 3: Reporting pipeline
- Expand Notion export/normalize workflows.
- Add schema validation for report fields before GIS conversion.
- Add artifact traceability and provenance checks.

## Phase 4: Degraded comms
- Formalize degraded communication SOPs and escalation paths.
- Add deterministic reconciliation workflow from edge to cloud.
- Conduct tabletop and live pilot failover exercises.

## Phase 5: Observability
- Add basic host/service telemetry collection patterns.
- Define pilot SLO-style indicators (availability, backup freshness, sync lag).
- Add runbook-driven alert response templates.

## Phase 6: Hardening
- Tighten network policy and SSH posture.
- Improve secret handling integration with managed vault tooling.
- Add security review gates and periodic recovery drills.
