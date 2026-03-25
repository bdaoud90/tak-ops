# Threat Model (Pilot)

## Key risks
- Credential leakage in automation pipelines.
- Internet exposure of management ports.
- Tampering of backups and restore media.
- Data inconsistency after degraded-mode recovery.

## Mitigations
- Keep secrets in environment or external secret managers.
- Restrict firewall and SSH origin ranges.
- Encrypt backups and log restore events.
- Run post-recovery smoke and integrity checks.
