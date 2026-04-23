# TAK Debugging Checkpoint — 2026-04-12

## Purpose
Record the operational checkpoint reached after TAK 5.7 bring-up/debug on Ubuntu 24.04 so future operators can restart from a known baseline.

## Environment normalization note
- **Validated environment for this checkpoint: Ubuntu 24.04**.
- Historical planning and early repo scaffolding included Ubuntu 22.04 references; these are retained as historical context, not current deployment truth.

## Initial state
- Deployment was unstable with mixed service signals.
- Wrapper-level service status did not reliably indicate end-to-end readiness.
- Client validation could not proceed due to backend and TLS uncertainty.

## Major blockers encountered
1. PostgreSQL ambiguity:
   - Wrapper/system service views suggested acceptable state while actual cluster health was degraded.
2. PostgreSQL startup reliability:
   - Memory settings on a small droplet prevented reliable cluster startup.
3. Certificate lifecycle drift:
   - Stale CA artifacts and password mismatches created misleading TLS failure symptoms.
4. Configuration alignment issues:
   - `CoreConfig.xml` keystore/truststore password mismatches blocked listener bring-up.
5. Signal-to-noise during startup:
   - Plugin stack traces complicated diagnosis of core service readiness.

## Pivots that moved troubleshooting forward
1. Switched DB truth check to `pg_lsclusters`.
2. Tuned PostgreSQL memory configuration for host constraints.
3. Regenerated cert material from clean state after removing stale CA/artifacts.
4. Aligned `CoreConfig.xml` keystore/truststore credentials and keymanager details.
5. Shifted debugging workflow to per-service logs under `/opt/tak/logs`.
6. Confirmed readiness with socket-level verification (`ss -ltnp`) plus log corroboration.

## Final successful checkpoint (verified)
- Listener ports confirmed active:
  - `8089` (primary client TLS path with pre-issued cert workflow)
  - `8443` (HTTPS/API path)
  - `8446` (alternate cert-auth HTTPS path)
- API, messaging, and retention logs showed expected startup patterns.
- System state moved from exploratory debugging to MVP demo baseline.

## Client validation direction captured at checkpoint
1. Prefer WinTAK and CivTAK onboarding against `178.62.235.44:8089` after importing client `.p12`.
2. Use `8446` as fallback diagnostic path when cert-auth behavior needs isolation.
3. Keep `8443` for web/API checks, not primary client enrollment.
4. Observe live server logs and socket activity during each connection attempt.

## Operational constraints discovered
- Android clients can hit trust/client-cert conflicts depending on device and OS policy.
- Cert distribution may require SCP staging workaround:
  - Copy from `/opt/tak/certs/files/` to `/home/ubuntu/`
  - Then transfer via SCP from `/home/ubuntu/`

## Verified vs Unresolved vs Backlog

**Verified**
- Ubuntu 24.04 was the effective, working platform at this checkpoint.
- `8089` + pre-issued certs is the most reliable first-pass client workflow.
- `8443` and `8446` are active and useful when used for their intended roles.

**Unresolved**
- Android trust and client-cert interaction remains inconsistent by device.
- Plugin subsystem noise still affects troubleshooting clarity.

**Backlog**
- Standardize cert export SOP (including `/home/ubuntu/` staging + cleanup).
- Create Android troubleshooting matrix by device/OS.
- Implement CRL/OCSP and validate resulting behavior.
