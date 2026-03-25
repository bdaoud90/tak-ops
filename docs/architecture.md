# Architecture

## Components
1. DigitalOcean droplet (Ubuntu 22.04) for TAK services.
2. Attached block volume for persistent data and backups.
3. Firewall limiting ingress to required ports.
4. Optional DNS record for service endpoint.
5. Raspberry Pi edge node for local continuity under comms degradation.

## Design goals
- Pilot-first with simple blast radius.
- Explicit automation boundaries.
- Clear audit trail from IaC and scripts.

## Trust boundaries
- Public internet -> reverse proxy/TLS endpoint.
- Internal service network on host.
- Offline edge environment with delayed sync workflows.
