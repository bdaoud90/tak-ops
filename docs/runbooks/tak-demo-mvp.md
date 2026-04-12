# TAK 5.7 Demo MVP Runbook (Ubuntu 24.04)

## Goal
Bring the current TAK Server deployment to a reproducible **demo-ready state** for:
- WinTAK (Windows) client connectivity validation
- CivTAK (Android) client connectivity validation

This runbook reflects the operational checkpoint captured on **2026-04-12**.

## Scope and assumptions
- Host: DigitalOcean droplet running Ubuntu 24.04
- TAK: package deployment under `/opt/tak`
- Service wrapper: `/etc/init.d/takserver`
- PostgreSQL: version 15
- Public test endpoint: `178.62.235.44`

---

## 1) Server-side verification checklist

Run these checks in order before client enrollment.

### 1.1 PostgreSQL cluster truth check
```bash
pg_lsclusters
```
Expected pattern:
- cluster `15 main` appears as `online`

Cross-check (supplementary only):
```bash
systemctl status postgresql --no-pager
```

### 1.2 Database reachability as TAK repository user
```bash
sudo -u postgres psql -d cot -c "SELECT 1;"
sudo -u postgres psql -d cot -c "SHOW max_connections;"
psql "postgresql://martiuser@127.0.0.1:5432/cot" -c "SELECT current_user, current_database();"
```
Expected pattern:
- `SELECT 1` succeeds
- `SHOW max_connections` returns `100`
- `martiuser` connects to database `cot`

### 1.3 Verify cert/keystore artifacts exist
```bash
ls -l /opt/tak/certs/files/{takserver.jks,takserver.p12,truststore-root.jks,fed-truststore.jks,admin.p12,user.p12}
```
Expected pattern:
- all listed files exist
- files are readable by TAK runtime user

Validate keystore password correctness:
```bash
keytool -list -keystore /opt/tak/certs/files/takserver.jks
```
Expected pattern:
- command succeeds with configured keystore password

### 1.4 Listener verification
```bash
ss -ltnp | rg ':(8089|8443|8446)\b'
```
Expected pattern includes:
- `0.0.0.0:8089`
- `0.0.0.0:8443`
- `0.0.0.0:8446`

### 1.5 Per-service log health check
```bash
tail -n 100 /opt/tak/logs/takserver-api.log
tail -n 100 /opt/tak/logs/takserver-messaging.log
tail -n 100 /opt/tak/logs/takserver-retention.log
tail -n 100 /opt/tak/logs/takserver-config.log
tail -n 100 /opt/tak/logs/takserver-plugins.log
```
Expected pattern:
- API log shows Tomcat initialization on 8443/8444/8446
- Messaging log shows normal startup; CRL/OCSP warning may appear (non-blocking for MVP)
- Retention log shows database pool startup

---

## 2.1 CoreConfig.xml effective state to preserve

Current effective configuration lessons:
- Listener definitions include:
  - `8089` (`stdssl` TLS ingest)
  - `8090` (`quic`)
  - `8443` (HTTPS)
  - `8444` (federation HTTPS)
  - `8446` (cert HTTPS)
- Repository block should remain aligned to PostgreSQL local endpoint:
  - JDBC URL: `jdbc:postgresql://127.0.0.1:5432/cot`
  - DB user: `martiuser`
- Keystore/truststore passwords in `CoreConfig.xml` must exactly match cert generation inputs.
- Keymanager value is case-sensitive and should be `SunX509`.
- Use `127.0.0.1` consistently instead of mixed localhost naming unless a deliberate reason exists.

---

## 2) Key troubleshooting lessons (operator notes)

1. **Use `pg_lsclusters` as source of truth** for PostgreSQL health; wrapper/systemd views alone can mislead.
2. **Cert regeneration requires clean state** when passwords drift: stale CA and old generated artifacts can poison the next run.
3. **`CoreConfig.xml` password alignment is mandatory**: keystore/truststore password mismatches can prevent listeners from opening without obvious top-level failure signals.
4. **Per-service logs matter more than wrapper status**: debug each TAK subservice independently.

---

## 3) Demo-ready current state (known good)

A known-good MVP baseline includes:
- PostgreSQL 15 cluster online
- `cot` DB reachable
- `martiuser` able to connect (temporarily elevated to `SUPERUSER` during troubleshooting)
- Core listeners online on:
  - `8443` (HTTPS)
  - `8446` (cert-auth HTTPS endpoint for first client tests)
  - `8089` (TLS ingest)
- API/messaging/retention startup logs showing normal initialization

---

## 4) WinTAK client test procedure (Windows)

### 4.1 Prepare certificate
1. On server, copy one client cert bundle from `/opt/tak/certs/files/`:
   - `admin.p12` (admin identity), or
   - `user.p12` (standard user identity)
2. Transfer securely to Windows test workstation.

### 4.2 Import in WinTAK
1. Open WinTAK certificate/import workflow.
2. Import the selected `.p12` using the correct import password.
3. Confirm certificate appears in client identity/cert store.

### 4.3 Configure server endpoint
- Host/IP: `178.62.235.44`
- Primary test port: `8446`
- Rationale:
  - `8446` is first direct cert-auth endpoint to validate client enrollment path.
  - `8443` is primarily web/API path.
  - `8089` is TLS ingest path and not first-choice for initial direct UI enrollment testing.

### 4.4 Observe server during connection attempts
On server, run in parallel:
```bash
tail -f /opt/tak/logs/takserver-api.log /opt/tak/logs/takserver-messaging.log
ss -tnp | rg ':8446\b'
```
Watch for:
- new inbound TCP sessions to `:8446`
- successful auth/session log entries (or clear TLS/cert errors)

---

## 5) CivTAK client test procedure (Android)

### 5.1 Prepare certificate
1. Copy `user.p12` from `/opt/tak/certs/files/`.
2. Transfer to Android device securely.

### 5.2 Import in CivTAK
1. Open CivTAK certificate management/import.
2. Import `user.p12` with correct password.
3. Confirm identity certificate is active.

### 5.3 Configure connection
- Server: `178.62.235.44`
- Port: `8446` (start here)

### 5.4 Validate basic data flow
After connecting:
1. Confirm connection status in CivTAK.
2. Send a simple marker or position update.
3. Verify server logs reflect inbound activity and no critical TLS/auth failures.

---

## 6) Post-demo hardening backlog

Track and execute after MVP connectivity validation:
1. Enable and validate CRL/OCSP revocation checking.
2. Remove temporary DB `SUPERUSER` elevation from `martiuser`; apply least-privilege grants.
3. Reintroduce/tune plugins and federation only after stable client baseline is confirmed.
4. Audit `CoreConfig.xml` for unnecessary complexity and normalize localhost references to `127.0.0.1` where appropriate.

---

## 7) Fast rollback / triage prompts

If client onboarding fails unexpectedly:
1. Re-run listener check (`ss -ltnp`).
2. Re-run `pg_lsclusters` and DB reachability checks.
3. Validate keystore with `keytool -list`.
4. Inspect per-service logs under `/opt/tak/logs` before changing runtime config.
