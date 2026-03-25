# Backup Verification Checklist

## Daily/Per-change checks
- [ ] Latest backup archive exists in expected location.
- [ ] Archive filename timestamp is current and UTC-based.
- [ ] Backup size is within expected range.
- [ ] Backup job logs show successful completion.

## Restore verification checks
- [ ] Restore test executed on non-production target.
- [ ] Restored files have expected ownership/permissions.
- [ ] Smoke test passed post-restore.
- [ ] Critical pilot data spot-check completed.

## Governance
- [ ] Retention policy confirmed.
- [ ] Offsite/archive transfer validated.
- [ ] Verification evidence attached to change record.
