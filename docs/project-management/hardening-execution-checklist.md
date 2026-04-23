# Hardening Execution Checklist

Use this checklist to execute hardening work in a deterministic sequence. Complete each phase in order and do not mark a phase done until all acceptance criteria are satisfied.

---

## Phase 1 — Baseline Repo Audit

### Inputs
- [ ] Current repository snapshot (default branch + active branch diffs).
- [ ] Existing documentation set (README, runbooks, known issues, architecture docs, timeline docs).
- [ ] Existing scripts/configs related to ACLED ingestion, operator packaging, and bootstrap.

### Outputs
- [ ] Inventory of files to be **updated**.
- [ ] Inventory of **net-new** files to be created.
- [ ] Short risk log for uncertain ownership, missing context, or dependency constraints.

### Acceptance criteria
- [ ] Every planned change is mapped to either “update existing” or “net-new.”
- [ ] No in-scope area (docs, ACLED feature, packaging/bootstrap, validation) is missing from the inventory.
- [ ] Inventory is reviewable by another implementer without additional context.

### Do not overstate guardrails
- [ ] Do not claim Android readiness unless Android-specific build/test evidence exists.
- [ ] Do not imply proprietary TAK internals are modified if only OSS or integration-layer artifacts are changed.
- [ ] Clearly label assumptions as assumptions.

---

## Phase 2 — Documentation Corrections

### Inputs
- [ ] Phase 1 audit inventory.
- [ ] Source-of-truth behavior from current scripts/configuration.
- [ ] Existing docs requiring updates (README, runbooks, known issues, architecture, timeline).

### Outputs
- [ ] Updated README reflecting current setup/operation reality.
- [ ] Updated runbook(s) with verified commands.
- [ ] Updated known-issues section/file with current caveats and mitigations.
- [ ] Updated architecture and timeline docs aligned with actual implementation status.

### Acceptance criteria
- [ ] Documentation changes are internally consistent (no contradictory steps or statuses).
- [ ] Commands in docs are executable as written (or explicitly marked as examples/placeholders).
- [ ] Status language reflects current state (implemented, partial, planned) with no ambiguity.

### Do not overstate guardrails
- [ ] Do not represent planned items as delivered.
- [ ] Do not imply Android production readiness without explicit validation artifacts.
- [ ] Do not describe proprietary TAK capabilities beyond documented public/integration boundaries.

---

## Phase 3 — ACLED Feature Delivery

### Inputs
- [ ] Feature requirements for ACLED ingestion/processing.
- [ ] Existing ACLED-related code paths and environment conventions.
- [ ] Documentation standards from Phase 2.

### Outputs
- [ ] ACLED script implementation (or update) committed.
- [ ] Environment template for ACLED configuration.
- [ ] ACLED runbook with setup + execution + troubleshooting steps.
- [ ] Optional: dedicated requirements/readme updates when dependency or usage clarity requires it.

### Acceptance criteria
- [ ] Script behavior is documented and reproducible from the runbook.
- [ ] Environment template includes all required variables with safe/example values.
- [ ] Failure modes and operator actions are documented (auth issues, rate limits, empty datasets, etc.).

### Do not overstate guardrails
- [ ] Do not claim data completeness, timeliness, or SLA guarantees not backed by monitoring/evidence.
- [ ] Do not claim Android client compatibility unless explicitly tested against Android targets.
- [ ] Do not imply access to proprietary TAK services or schemas unless formally available and validated.

---

## Phase 4 — Operator Packaging / Bootstrap Scripts

### Inputs
- [ ] Existing packaging/bootstrap scripts and runtime assumptions.
- [ ] Target operator workflow (fresh install, upgrade, rollback expectations).
- [ ] Outputs from Phases 2–3.

### Outputs
- [ ] Updated or net-new operator packaging scripts.
- [ ] Updated or net-new bootstrap scripts with clear prerequisites.
- [ ] Operator-focused usage notes integrated into docs/runbooks.

### Acceptance criteria
- [ ] Bootstrap path works from a clean environment using documented prerequisites.
- [ ] Packaging artifacts and naming/versioning conventions are consistent.
- [ ] Error handling/messages are actionable for operators.

### Do not overstate guardrails
- [ ] Do not present bootstrap automation as universal if OS/shell/environment caveats exist.
- [ ] Do not claim Android deployment automation unless Android path is implemented and verified.
- [ ] Do not blur OSS packaging with proprietary TAK distribution responsibilities.

---

## Phase 5 — Validation Pass

### Inputs
- [ ] All modified docs/scripts from Phases 1–4.
- [ ] Validation checklist (cross-links, commands, shell syntax, tests).
- [ ] Any unit tests introduced for ACLED logic.

### Outputs
- [ ] Verified docs cross-links (no broken internal references).
- [ ] Verified command correctness (spot-checked in shell).
- [ ] Shell syntax check results for changed scripts.
- [ ] ACLED unit test results (if tests were added).

### Acceptance criteria
- [ ] Validation evidence is captured (command logs or CI output references).
- [ ] Any failures are fixed or explicitly deferred with rationale.
- [ ] No phase is marked complete with unresolved critical validation issues.

### Do not overstate guardrails
- [ ] Do not report “validated” if checks were skipped; mark as deferred with reason.
- [ ] Do not claim production readiness from lint/unit checks alone.
- [ ] Do not imply proprietary TAK end-to-end validation unless that environment was actually exercised.

---

## Phase 6 — Final Summary and Deferred Backlog

### Inputs
- [ ] Completed phase outputs and validation evidence.
- [ ] List of unresolved issues, risks, and non-blocking improvements.

### Outputs
- [ ] Final implementation summary (what changed, why, and impact).
- [ ] Deferred backlog with priority, owner (if known), and unblock conditions.
- [ ] Explicit note of any assumptions and validation gaps.

### Acceptance criteria
- [ ] Summary maps directly to delivered artifacts.
- [ ] Deferred items are actionable and not vague.
- [ ] Handover enables next implementer to continue without rediscovery.

### Do not overstate guardrails
- [ ] Do not characterize deferred work as complete.
- [ ] Do not claim Android hardening completeness unless Android-specific acceptance criteria passed.
- [ ] Do not imply scope crossed proprietary TAK boundaries without explicit authorization and evidence.

---

## Deterministic Progress Tracker

- [ ] Phase 1 complete
- [ ] Phase 2 complete
- [ ] Phase 3 complete
- [ ] Phase 4 complete
- [ ] Phase 5 complete
- [ ] Phase 6 complete
- [ ] Final review complete (all guardrails re-checked)
