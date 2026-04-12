# TAK Server Known Issues (Operational)

This document tracks recurrent operational issues observed during TAK 5.7 deployment/debug on Ubuntu 24.04.

## 1) Stale CA/private key artifacts poison cert regeneration

**Symptom**
- Cert regeneration appears to succeed partially, but runtime TLS endpoints fail or present inconsistent behavior.

**Likely cause**
- Existing CA key/material and generated artifacts were not removed before regenerating with new password inputs.

**Verification commands**
```bash
ls -l /opt/tak/certs/files/
keytool -list -keystore /opt/tak/certs/files/takserver.jks
```

**Fix / mitigation**
- Remove stale CA/generated files before rerun when password drift is suspected.
- Regenerate cert chain in a clean, controlled sequence.
- Immediately validate with `keytool -list` and startup logs.

---

## 2) `sudo` environment handling breaks cert scripts

**Symptom**
- Cert generation scripts fail unexpectedly, or produce artifacts with wrong assumptions despite seemingly correct inputs.

**Likely cause**
- Running scripts with `sudo` dropped required environment variables.

**Verification commands**
```bash
env | sort
sudo env | sort
```
(Compare required cert-script variables between contexts.)

**Fix / mitigation**
- Preserve required env vars explicitly when elevating privileges.
- Use a documented invocation pattern for cert scripts; avoid ad hoc shell state.

---

## 3) PostgreSQL wrapper status appears healthy while cluster is down

**Symptom**
- TAK services fail DB-dependent startup but `systemctl status postgresql` appears superficially acceptable.

**Likely cause**
- Actual PostgreSQL cluster (`15/main`) is not running.

**Verification commands**
```bash
pg_lsclusters
systemctl status postgresql --no-pager
```

**Fix / mitigation**
- Treat `pg_lsclusters` as primary cluster health check.
- Restart/repair the specific cluster and re-check DB connectivity from TAK user context.

---

## 4) Small-droplet memory settings prevent PostgreSQL startup

**Symptom**
- PostgreSQL cluster repeatedly fails to start on constrained host.

**Likely cause**
- Memory-related PostgreSQL settings too aggressive for available RAM.

**Verification commands**
```bash
pg_lsclusters
journalctl -u postgresql --no-pager -n 200
```

**Fix / mitigation**
- Lower memory-related PostgreSQL settings for host size.
- Restart cluster and confirm `online` state.

---

## 5) Plugin service introduces noisy/confusing startup failures

**Symptom**
- Stack traces from plugin subsystem (for example `PluginService.canAccessPluginDataFeedApi(...)`) obscure core service health.

**Likely cause**
- Plugin initialization path fails independently while API/messaging/retention may still be recoverable.

**Verification commands**
```bash
tail -n 200 /opt/tak/logs/takserver-plugins.log
tail -n 200 /opt/tak/logs/takserver-api.log
tail -n 200 /opt/tak/logs/takserver-messaging.log
```

**Fix / mitigation**
- Triage plugin issues separately from core MVP listener bring-up.
- For MVP demos, prioritize stable core path first; revisit plugins after baseline client connectivity is proven.

---

## 6) TLS active without CRL/OCSP validation

**Symptom**
- Messaging service logs warning that TLS is enabled but revocation checks are not configured.

**Likely cause**
- CRL/OCSP validation not enabled in current runtime configuration.

**Verification commands**
```bash
rg -n "CRL|OCSP|revocation" /opt/tak/logs/takserver-messaging.log
```

**Fix / mitigation**
- Track as security hardening item (non-blocking for MVP functional testing).
- Implement CRL/OCSP policy and verify log behavior after deployment.
