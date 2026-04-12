# TAK Service Map (from `/etc/init.d/takserver` behavior)

## Overview
In this deployment, `/etc/init.d/takserver` acts as a **wrapper orchestrator** for multiple TAK services. Operationally, this behaves like a small service suite rather than one monolithic daemon.

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
- Relevant to ingest port behavior (`8089`) and TLS warning visibility (CRL/OCSP messages).

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
- `8443` bound: primary HTTPS/API path is up.
- `8446` bound: cert-auth client path available for initial WinTAK/CivTAK connectivity tests.
- `8089` bound: TLS ingest path up.

Important: bound ports are necessary but not sufficient. Always correlate with per-service logs and DB health.
