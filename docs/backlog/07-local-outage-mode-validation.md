# Title
Local outage-mode validation

## Problem
Outage-mode SOP exists, but pilot needs practical validation to confirm operators can continue local operations and recover cleanly.

## Desired outcome
A documented outage drill proving degraded operation and controlled recovery.

## Acceptance criteria
- Simulated WAN outage exercise executed.
- Operators follow outage-mode SOP steps without gaps.
- Local capture/queue behavior is demonstrated.
- Recovery steps complete with smoke-test pass.
- Post-incident notes captured with improvement actions.

## Dependencies
- Edge node bootstrap complete.
- Baseline cloud deployment reachable pre/post drill.

## Notes/Risks
- Drill should be scheduled to minimize operational impact.
- Data reconciliation edge cases may surface during recovery.
