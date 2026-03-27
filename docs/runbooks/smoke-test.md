# Runbook: Smoke Test

Use `scripts/smoke-test.sh` for layered connectivity checks.

## What it validates
1. TCP reachability to target port.
2. Optional HTTPS status check against `https://<target>:<port>`.

## Common examples
```bash
# Default behavior: TCP + HTTPS on 443
./scripts/smoke-test.sh --target tak-dev.example.org

# TCP-only check
./scripts/smoke-test.sh --target tak-dev.example.org --port 8089 --skip-https

# HTTPS with explicit expected response code
./scripts/smoke-test.sh --target tak-dev.example.org --expect-code 302
```

## Notes
- This runbook intentionally validates transport reachability only.
- It does not claim to validate proprietary TAK internals.
- Record outcome in pilot change log after each deployment or recovery event.
