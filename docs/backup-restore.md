# Backup and Restore

## Backup
- Automated Ansible role installs a lightweight cron placeholder.
- Preferred on-demand backup wrapper: `scripts/backup.sh`.
- `scripts/backup.sh` outputs:
  - archive path (`.tar.gz`)
  - SHA-256 checksum path (`.tar.gz.sha256`)

Example:
```bash
./scripts/backup.sh --source /opt/tak --dest /var/backups/tak --name tak
```

## Restore
- `scripts/restore.sh` now defaults to **staging restore**, not `/`.
- Default destination: `/var/tmp/tak-restore`.
- Live restore into `/` is blocked unless `--live-restore` is explicitly set.

Examples:
```bash
# Safe staging restore (default)
./scripts/restore.sh --archive /var/backups/tak/tak-20260101T000000Z.tar.gz

# Explicit staging path
./scripts/restore.sh --archive /var/backups/tak/tak-20260101T000000Z.tar.gz --destination /tmp/tak-restore

# Dangerous live restore (explicit opt-in required)
./scripts/restore.sh --archive /var/backups/tak/tak-20260101T000000Z.tar.gz --destination / --live-restore
```

## Service-state caveat
- This scaffold does not orchestrate application-consistent snapshots.
- **Manual operator step**: coordinate backup timing with TAK service state and vendor-recommended quiesce/restart procedures.

## Manual checkpoints
- **Manual operator step**: store backups in your approved offsite/archive system.
- **Manual operator step**: validate checksum verification and retention policy with compliance owner.
- **Manual operator step**: run a restore drill in staging before pilot go-live.
