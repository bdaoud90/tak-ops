# TAK Service Map (from `/etc/init.d/takserver` behavior)

## Overview
In this deployment, `/etc/init.d/takserver` acts as a **wrapper orchestrator** for multiple TAK services. Operationally, this behaves like a small service suite rather than one monolithic daemon.

Validated runtime baseline:
- Host OS: Ubuntu 24.04
- Historical note: some older planning docs referenced Ubuntu 22.04; current service behavior in this map is based on 24.04 observations

### Services launched by wrapper
- `takserver-config`
- `takserver-messaging`
- `takserver-api`
- `takserver-plugins`
- `takserver-retention`

## High-level role of each service (operational inference)

> These descriptions are based on observed startup/log behavior and are intended as operator guidance.

### `takserver-config`
- Loads/validates runtime configuration and shared initialization state.
- Early failures here can cascade into downstream service startup issues.

### `takserver-messaging`
- Handles message transport path(s), including TLS ingest listener behavior.
- Relevant to primary client path (`8089`) and TLS warning visibility (CRL/OCSP messages).

### `takserver-api`
- Hosts HTTPS/Tomcat-facing endpoints.
- In known-good state, initializes listeners associated with `8443`, `8444`, and `8446`.

### `takserver-plugins`
- Initializes plugin subsystem.
- Has produced noisy stack traces during troubleshooting and can obscure core readiness signal.

### `takserver-retention`
- Handles retention/background data lifecycle tasks with DB pool dependencies.
- Useful signal for database readiness in full stack startup.

## Why debug per service (not wrapper only)

Wrapper health can be misleading:
- One or more child services can fail while others bind ports.
- A partial startup may look "up" from wrapper/systemd view.
- Correct troubleshooting requires service-specific log review.

## Log-to-service mapping

Primary logs under `/opt/tak/logs/`:
- `takserver-config.log` → config service
- `takserver-messaging.log` → messaging service
- `takserver-api.log` → API/Tomcat service
- `takserver-plugins.log` → plugin service
- `takserver-retention.log` → retention service

## Port binding and health correlation

Use listener checks to confirm externally observable readiness:
```bash
ss -ltnp | rg ':(8089|8443|8446)\b'
```

Operational interpretation:
- `8089` bound: primary TAK client TLS path available (WinTAK/CivTAK with pre-issued certs).
- `8446` bound: alternate certificate-auth HTTPS validation path available.
- `8443` bound: HTTPS/API/web path available.

Important: bound ports are necessary but not sufficient. Always correlate with per-service logs and DB health.

## Client-path architecture note (operator guidance)

For current MVP operations:
- Prefer `8089` as primary client onboarding connection target after certificate import.
- Use `8446` for fallback diagnostics and alternate cert-auth checks.
- Keep `8443` for API/web administrative flows.

Android-specific caveat:
- CivTAK on Android can exhibit trust/client-cert conflict behavior depending on OS build and credential store policy; this is an operational limitation, not a proven server-side mapping fault.

SCP operational note:
- If client certs under `/opt/tak/certs/files/` are not directly readable by transfer user, stage to `/home/ubuntu/` first before SCP distribution.

## Verified vs Unresolved vs Backlog

**Verified**
- Multi-service wrapper behavior requires per-service log diagnostics.
- `8089`/`8446`/`8443` role split above matches current observed operations.
- Ubuntu 24.04 baseline behavior is documented and repeatable at checkpoint level.

**Unresolved**
- Plugin noise can mask failure boundaries during partial startup.
- Android trust + client-cert interactions remain variable.

**Backlog**
- Add diagram artifact showing port/service/client-path relationships.
- Add a dedicated troubleshooting flowchart for Android handshake failures.
