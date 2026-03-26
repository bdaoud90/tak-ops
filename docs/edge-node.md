# Edge Node (Raspberry Pi)

The edge node is isolated in Ansible inventory group `edge_nodes` and configured by `playbooks/edge-node.yml`.

## Purpose
- Maintain local operations during WAN disruption.
- Support staged synchronization back to cloud after recovery.

## Baseline requirements
- Raspberry Pi OS 64-bit or Ubuntu Server for Pi.
- SSH connectivity from operator workstation.
- Stable local power and network.

## Setup sequence
1. Add node under `edge_nodes` in inventory.
2. Run `scripts/bootstrap-edge.sh --inventory <inventory>`.
3. Validate expected packages/services and local cache directory.
4. Run outage-mode drill with clients.

## Validation checks
- Edge host reachable over SSH.
- `edge_node` role run succeeds idempotently.
- Local cache path exists.
- Operators can execute degraded-mode SOP.

## Manual boundaries
- Manual operator step: integrate any radio/comms middleware outside repo scope.
