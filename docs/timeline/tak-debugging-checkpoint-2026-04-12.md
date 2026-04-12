# TAK Debugging Checkpoint — 2026-04-12

## Purpose
Record the operational checkpoint reached after TAK 5.7 bring-up/debug on Ubuntu 24.04 so future operators can restart from a known baseline.

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
  - `8443`
  - `8446`
  - `8089`
- API, messaging, and retention logs showed expected startup patterns.
- System state moved from exploratory debugging to MVP demo baseline.

## Current next step
Proceed to client validation:
1. WinTAK enrollment/connectivity test against `178.62.235.44:8446` using imported client `.p12`.
2. CivTAK enrollment/connectivity test against `178.62.235.44:8446` using imported `user.p12`.
3. Observe live server logs and socket activity during each connection attempt.
