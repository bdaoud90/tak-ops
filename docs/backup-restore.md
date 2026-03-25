# Backup and Restore

## Backup
- Automated role installs a scheduled backup job.
- On-demand backup via `scripts/backup.sh`.

## Restore
- Use `scripts/restore.sh <archive>` for controlled restore operations.
- Restore should always be followed by smoke testing.

## Manual checkpoints
- **Manual operator step**: Store backups in your approved offsite/archive system.
- **Manual operator step**: Validate retention policy with compliance owner.
