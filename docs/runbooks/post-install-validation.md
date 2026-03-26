# Runbook: Post-Install Validation (Manual TAK Install)

## Purpose
Validate baseline expectations after manual installation of restricted TAK components.

## Expected service/process checks
- Identify expected service names from your TAK deployment (example placeholders: `takserver`, `tak-db`).
- Confirm each required service is active.

## Expected file/location checks
- Installation root (example: `/opt/tak`).
- Config directory (example: `/opt/tak/config`).
- Cert/key paths (example: `/opt/tak/certs`).
- Runtime/log paths as defined by your deployment.

## Command pattern
```bash
./scripts/post-install-validate.sh \
  --service takserver \
  --service tak-db \
  --path /opt/tak \
  --path /opt/tak/config \
  --path /opt/tak/certs
```

## Operator checklist
- [ ] Manual install completed from authorized artifacts.
- [ ] Expected services active.
- [ ] Expected config/cert/key files present with proper permissions.
- [ ] Layered smoke test passed.
- [ ] Backup created after validated install.
