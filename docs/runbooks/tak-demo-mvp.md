# TAK 5.7 Demo MVP Runbook (Ubuntu 24.04)

## Goal
Bring the current TAK Server deployment to a reproducible **demo-ready state** for:
- WinTAK (Windows) client connectivity validation
- CivTAK (Android) client connectivity validation

This runbook reflects the operational checkpoint captured on **2026-04-12**.

## Scope and assumptions
- Host: DigitalOcean droplet running Ubuntu 24.04 (**validated environment**)
- Historical note: earlier planning referenced Ubuntu 22.04, but the verified checkpoint environment is 24.04
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

## 2) CoreConfig.xml effective state to preserve

Current effective configuration lessons:
- Listener definitions include:
  - `8089` (`stdssl` TLS ingest)
  - `8090` (`quic`)
  - `8443` (HTTPS/API)
  - `8444` (federation HTTPS)
  - `8446` (certificate-auth HTTPS)
- Repository block should remain aligned to PostgreSQL local endpoint:
  - JDBC URL: `jdbc:postgresql://127.0.0.1:5432/cot`
  - DB user: `martiuser`
- Keystore/truststore passwords in `CoreConfig.xml` must exactly match cert generation inputs.
- Keymanager value is case-sensitive and should be `SunX509`.
- Use `127.0.0.1` consistently instead of mixed localhost naming unless a deliberate reason exists.

---

## 3) Key troubleshooting lessons (operator notes)

1. **Use `pg_lsclusters` as source of truth** for PostgreSQL health; wrapper/systemd views alone can mislead.
2. **Cert regeneration requires clean state** when passwords drift: stale CA and old generated artifacts can poison the next run.
3. **`CoreConfig.xml` password alignment is mandatory**: keystore/truststore password mismatches can prevent listeners from opening without obvious top-level failure signals.
4. **Per-service logs matter more than wrapper status**: debug each TAK subservice independently.

---

## 4) Demo-ready current state (known good)

A known-good MVP baseline includes:
- PostgreSQL 15 cluster online
- `cot` DB reachable
- `martiuser` able to connect (temporarily elevated to `SUPERUSER` during troubleshooting)
- Core listeners online on:
  - `8443` (HTTPS/API)
  - `8446` (certificate-auth HTTPS path)
  - `8089` (TLS ingest)
- API/messaging/retention startup logs showing normal initialization

---

## 5) WinTAK client test procedure (Windows)

### 5.1 Prepare certificate and stage to operator workstation
1. On server, choose one client cert bundle from `/opt/tak/certs/files/`:
   - `admin.p12` (admin identity), or
   - `user.p12` (standard user identity)
2. If direct copy is blocked by permission/path policy, use staging workaround:
   ```bash
   sudo cp /opt/tak/certs/files/user.p12 /home/ubuntu/
   sudo chown ubuntu:ubuntu /home/ubuntu/user.p12
   ```
3. Transfer to Windows with SCP (example):
   ```bash
   scp ubuntu@178.62.235.44:/home/ubuntu/user.p12 .
   ```

### 5.2 Import in WinTAK
1. Open WinTAK certificate/import workflow.
2. Import the selected `.p12` using the correct import password.
3. Confirm certificate appears in client identity/cert store.

### 5.3 Configure server endpoint (primary)
- Host/IP: `178.62.235.44`
- **Primary test port: `8089`**
- Workflow: TLS + pre-issued client cert imported into WinTAK first

Role distinctions (retain for operators):
- `8089`: primary TAK client connection path for MVP onboarding.
- `8446`: certificate-auth HTTPS endpoint for alternate/troubleshooting validation.
- `8443`: HTTPS/API/web path, not the primary WinTAK enrollment path.

### 5.4 Observe server during connection attempts
On server, run in parallel:
```bash
tail -f /opt/tak/logs/takserver-api.log /opt/tak/logs/takserver-messaging.log
ss -tnp | rg ':(8089|8446)\b'
```
Watch for:
- new inbound TCP sessions to `:8089` (or `:8446` if doing alternate path test)
- successful auth/session log entries (or clear TLS/cert errors)

---

## 6) CivTAK client test procedure (Android)

### 6.1 Prepare certificate
1. Copy `user.p12` from `/opt/tak/certs/files/`.
2. If needed, stage first to `/home/ubuntu/` then SCP/ADB transfer (same workaround pattern as WinTAK prep).
3. Transfer to Android device securely.

### 6.2 Import in CivTAK
1. Open CivTAK certificate management/import.
2. Import `user.p12` with correct password.
3. Confirm identity certificate is active.

### 6.3 Configure connection
- Server: `178.62.235.44`
- Start with port: `8089`
- Keep `8446` as fallback troubleshooting path.

### 6.4 Android limitations and trust/client-cert conflict notes
- Android behavior varies by version and OEM policy for user-installed credentials.
- On some devices, enabling strict server trust checks while also using a user-installed client certificate can produce handshake failures.
- If connection fails after certificate import:
  1. Reconfirm `.p12` password/import success.
  2. Re-test on `8089` first, then `8446`.
  3. Review server logs for TLS alert/handshake clues.
  4. Document device model + Android version for repeatability.

### 6.5 Validate basic data flow
After connecting:
1. Confirm connection status in CivTAK.
2. Send a simple marker or position update.
3. Verify server logs reflect inbound activity and no critical TLS/auth failures.

---

## 7) Verified vs Unresolved vs Backlog

**Verified**
- Ubuntu 24.04 host is current validated environment.
- WinTAK/CivTAK primary onboarding path is `8089` with pre-issued client certs.
- `8443`/`8446` remain available and documented with distinct role boundaries.

**Unresolved**
- Android trust-store/client-cert interaction is not uniformly predictable across devices.
- Plugin log noise can still complicate rapid root-cause isolation.

**Backlog**
- Enable and validate CRL/OCSP revocation checking.
- Remove temporary DB `SUPERUSER` elevation from `martiuser`; apply least-privilege grants.
- Build a tested Android matrix (device + OS + cert import path + outcome).

---

## 8) Fast rollback / triage prompts

If client onboarding fails unexpectedly:
1. Re-run listener check (`ss -ltnp`).
2. Re-run `pg_lsclusters` and DB reachability checks.
3. Validate keystore with `keytool -list`.
4. Inspect per-service logs under `/opt/tak/logs` before changing runtime config.
