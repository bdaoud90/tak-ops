# Backup and Restore

## Backup behavior
- `scripts/backup.sh` creates a tar archive and adjacent `.sha256` checksum file.
- Archive and checksum should be stored together.

## Restore behavior (safe-by-default)
- `scripts/restore.sh` verifies checksum by default.
- Restore extracts to staging directory unless `--live-restore` is explicitly provided.
- Live restore prints warning banner and should be done only after service stop actions.

## Live restore guidance
1. Manual operator step: stop affected services.
2. Execute restore with `--live-restore --destination /` (or explicit path).
3. Manual operator step: restart services.
4. Run smoke test + post-install validation.

## Verification checklist
Use `docs/backup-verification-checklist.md` for routine and drill validation.
