# Architecture

## Pilot topology
- **1 cloud TAK server** on DigitalOcean (Ubuntu 22.04).
- **1 edge node** (Raspberry Pi) for degraded-mode continuity.
- **2 user clients** for demo/validation (networked to cloud in normal mode, edge workflow in outage mode).

## Components
1. DigitalOcean droplet hosts reverse proxy and TAK components.
2. Attached block volume stores persistent data and backups.
3. Firewall restricts ingress to explicit pilot transport ports.
4. Optional DNS maps FQDN to cloud endpoint.
5. Edge node hosts local fallback services/caches.

## Transport profile assumptions (pilot)
- TCP 22: operator SSH management.
- TCP 443: reverse proxy/TLS ingress.
- TCP 8089: placeholder application/backend port (adjust per deployment profile).
- UDP: disabled by default and only opened when explicitly required by operator-approved design.

> Manual operator step: confirm port/profile alignment with your TAK vendor deployment guidance.

## Trust boundaries
- Public internet -> reverse proxy boundary.
- Internal host services behind proxy and local controls.
- Edge node trusted local segment for degraded operation.

## Operational boundaries
- Restricted/proprietary TAK packages are **not** in this repo.
- Automation prepares host, network, and validation scaffolding.
- Manual installation remains mandatory for restricted components.
