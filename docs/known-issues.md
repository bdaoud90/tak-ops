# TAK Server Known Issues (Operational)

This document tracks recurrent operational issues observed during TAK 5.7 deployment/debug on Ubuntu 24.04 (validated environment). Historical references to earlier Ubuntu 22.04 planning assumptions are retained for context only.

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

---

## 7) Client endpoint confusion across `8089`, `8443`, and `8446`

**Symptom**
- Operators enroll clients on the wrong endpoint and observe handshake/auth failures.

**Likely cause**
- Prior guidance favored `8446` for first tests; current validated workflow favors `8089` with pre-issued certs.

**Verification commands**
```bash
ss -ltnp | rg ':(8089|8443|8446)\b'
tail -n 200 /opt/tak/logs/takserver-messaging.log
tail -n 200 /opt/tak/logs/takserver-api.log
```

**Fix / mitigation**
- Use `8089` TLS + pre-issued client cert as primary path.
- Keep role distinctions explicit:
  - `8089`: primary TAK client onboarding path.
  - `8446`: alternate cert-auth HTTPS path.
  - `8443`: HTTPS/API/web path.

---

## 8) Android trust/client-cert conflict and device variance

**Symptom**
- CivTAK import appears successful, but connection still fails with TLS handshake/trust errors.

**Likely cause**
- Android/OEM credential handling differs by device and OS, especially when user CA trust expectations and client-certificate use interact.

**Verification commands**
```bash
tail -n 200 /opt/tak/logs/takserver-messaging.log
ss -tnp | rg ':(8089|8446)\b'
```

**Fix / mitigation**
- Re-test against `8089` first, then `8446` fallback.
- Re-import `.p12` and verify password correctness.
- Record device model + Android version alongside failure mode.

---

## 9) SCP path/permission friction for client cert export

**Symptom**
- `scp` from `/opt/tak/certs/files/` fails due to permissions or policy constraints.

**Likely cause**
- Non-root operators cannot directly read export material in `/opt/tak/certs/files/`.

**Verification commands**
```bash
ls -l /opt/tak/certs/files/
```

**Fix / mitigation**
- Stage cert bundle to `/home/ubuntu/` before transfer:
```bash
sudo cp /opt/tak/certs/files/user.p12 /home/ubuntu/
sudo chown ubuntu:ubuntu /home/ubuntu/user.p12
scp ubuntu@<server-ip>:/home/ubuntu/user.p12 .
```

---

## Verified vs Unresolved vs Backlog

**Verified**
- Ubuntu 24.04 is the factual validated operating environment.
- `8089` TLS with pre-issued certs is the current primary client onboarding path.
- `8443`/`8446` are retained with specific, non-primary roles.
- SCP staging via `/home/ubuntu/` resolves common export path friction.

**Unresolved**
- Android trust/client-cert behavior remains inconsistent across device classes.
- Plugin subsystem still introduces troubleshooting noise.

**Backlog**
- Enforce CRL/OCSP in production profiles.
- Publish standardized cert-distribution SOP (including secure staging cleanup).
- Expand device-level CivTAK compatibility matrix.
