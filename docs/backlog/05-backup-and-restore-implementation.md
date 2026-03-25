# Title
Backup and restore implementation

## Problem
Backup scripts and role scaffolding exist, but operators need verified restore confidence and operational retention controls.

## Desired outcome
Reliable backup/restore workflow with verification evidence and clear ownership.

## Acceptance criteria
- Scheduled backup job runs successfully on target host.
- On-demand backup script produces timestamped archives.
- Restore script is tested on non-production target.
- Backup verification checklist is completed and attached to change record.
- Retention/offsite expectations are documented.

## Dependencies
- TAK installation paths finalized.
- Storage destination and retention policy agreed.

## Notes/Risks
- Unverified backups create false confidence.
- Restore tests must avoid destructive overlap with active services.
