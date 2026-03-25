# Title
Incident recovery runbook

## Problem
Recovery runbook exists at a high level and should be expanded to include decision points, communications, and verification checkpoints.

## Desired outcome
An actionable incident recovery runbook that supports repeatable restoration under pressure.

## Acceptance criteria
- Triage and containment steps are explicit.
- Backup selection criteria are documented.
- Restore + smoke test + data integrity checks are sequenced.
- Communications/escalation template included.
- Post-incident review checklist included.

## Dependencies
- Backup/restore implementation validated.
- On-call/escalation ownership defined.

## Notes/Risks
- Ambiguous ownership during incidents delays recovery.
- Missing integrity checks can reintroduce corrupted state.
