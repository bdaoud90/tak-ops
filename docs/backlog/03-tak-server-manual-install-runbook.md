# Title
TAK server manual install runbook

## Problem
Restricted/proprietary TAK components cannot be redistributed in this repository, so operators need a precise manual install procedure that aligns with automation boundaries.

## Desired outcome
A complete runbook for manual TAK component installation and verification without embedding restricted binaries.

## Acceptance criteria
- Runbook explicitly marks every "Manual operator step".
- Staging directory conventions are documented.
- Pre-install and post-install checks are documented.
- Smoke-test and backup checkpoint steps are included.
- Legal/licensing responsibilities are clearly called out.

## Dependencies
- Base host provisioning and hardening complete.
- Access to licensed TAK artifacts from authorized source.

## Notes/Risks
- Drift risk if manual steps are undocumented or skipped.
- Operator turnover requires readable, repeatable procedures.
