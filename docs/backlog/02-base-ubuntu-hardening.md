# Title
Base Ubuntu hardening

## Problem
Pilot hosts require a minimum hardening baseline beyond package installation to reduce exposure and enforce secure defaults.

## Desired outcome
Ansible hardening role applies a documented baseline on Ubuntu 22.04 and is idempotent.

## Acceptance criteria
- SSH root login is disabled.
- SSH configuration changes are validated and service restarts cleanly.
- UFW baseline policy is documented and applied.
- Hardening tasks are idempotent across two consecutive runs.
- Runbook includes rollback guidance for lockout scenarios.

## Dependencies
- Completed cloud provisioning.
- Confirmed operator access path for emergency recovery.

## Notes/Risks
- Misconfigured SSH hardening can lock operators out.
- Changes should be staged in dev before prod promotion.
