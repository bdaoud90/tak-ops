# Edge Node (Raspberry Pi)

The edge node provides local resilience when WAN connectivity is intermittent or unavailable.

## Baseline
- Raspberry Pi OS (64-bit) or Ubuntu Server for Pi.
- SSH access and operator key.
- Local time sync recommended (GPS/NTP where available).

## Setup
- Run `scripts/bootstrap-edge.sh`.
- Apply Ansible `edge-node.yml`.
- Validate local cache paths and radio/network interfaces.
