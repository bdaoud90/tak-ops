# Runbook: Smoke Test

Use layered smoke tests to validate:
1. network reachability
2. reverse proxy/TLS
3. backend service port
4. optional health URL and process checks

Example:
```bash
./scripts/smoke-test.sh \
  --target tak.example.com \
  --service-port 8089 \
  --health-url https://tak.example.com/health \
  --insecure
```
