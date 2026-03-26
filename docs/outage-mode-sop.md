# Outage-Mode SOP (Degraded Communications)

## Trigger conditions
- Cloud TAK endpoint unreachable for >5 minutes.
- Upstream WAN outage confirmed.
- Planned maintenance window requiring fallback operations.

## Actions
1. Declare degraded mode in operations channel.
2. Shift field operators to edge-node workflows.
3. Capture reports/events locally and queue sync payloads.
4. Increase comms cadence and incident logging frequency.
5. Preserve timeline of decisions for post-incident reconciliation.

## Recovery
1. Confirm cloud endpoint restored and stable.
2. Perform controlled synchronization from edge to cloud.
3. Run smoke test and data consistency checks.
4. End degraded mode and publish incident summary.
