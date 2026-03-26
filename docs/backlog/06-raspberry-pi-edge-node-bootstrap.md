# Title
Raspberry Pi edge node bootstrap

## Problem
Edge node role exists but requires pilot-specific validation for hardware/image variants and degraded-mode operations.

## Desired outcome
A repeatable Raspberry Pi bootstrap process validated on target pilot hardware.

## Acceptance criteria
- `bootstrap-edge.sh` runs with documented inventory and playbook options.
- Required edge packages are installed and services are healthy.
- Edge cache directory and local workflows are confirmed.
- Edge-node runbook includes operator prerequisites.
- Validation record captured from at least one test device.

## Dependencies
- Pi hardware and OS image selected.
- Network/SSH access to edge device.

## Notes/Risks
- Package differences across Pi OS variants may require conditional tasks.
- Field power/network instability may affect validation outcomes.
