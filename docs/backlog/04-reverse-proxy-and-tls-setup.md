# Title
Reverse proxy and TLS setup

## Problem
Current reverse proxy role is scaffold-level and needs validated TLS behavior and operational certificate handling decisions.

## Desired outcome
A pilot-ready reverse proxy configuration with documented certificate paths and secure defaults.

## Acceptance criteria
- Nginx config validates (`nginx -t`).
- HTTPS endpoint reachable for smoke tests.
- Certificate source process documented (ACME or external PKI).
- Cipher/protocol baseline documented for pilot.
- Config deploy is idempotent via Ansible.

## Dependencies
- Host provisioning complete.
- DNS/FQDN strategy decided.

## Notes/Risks
- Placeholder certs must not be used for production traffic.
- External PKI handoffs may add timing dependencies.
