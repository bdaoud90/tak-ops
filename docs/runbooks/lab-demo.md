# Runbook: Lab Demo (1 Cloud + 1 Edge + 2 Clients)

## Prerequisites
- Cloud server provisioned and configured.
- Edge node configured under `edge_nodes`.
- Two user devices with demo client setup.
- Manual TAK install completed on cloud host.
- Firewall/profile configured for pilot ports.

## Demo sequence
1. Run `./scripts/validate-config.sh`.
2. Run layered smoke test against cloud endpoint:
   ```bash
   ./scripts/smoke-test.sh --target <tak-fqdn> --service-port 8089
   ```
3. Execute post-install checks:
   ```bash
   ./scripts/post-install-validate.sh --service <svc> --path <path>
   ```
4. Connect both user clients to cloud endpoint and verify expected behavior.
5. Simulate outage (disconnect WAN path or block cloud route).
6. Shift operations to edge node per outage SOP.
7. Verify both clients can complete defined degraded-mode validation actions.
8. Restore normal connectivity and verify cloud path recovers.

## Success criteria
- Cloud smoke tests pass.
- Both clients validate normal-mode interactions.
- Degraded-mode workflow succeeds with edge node.
- Recovery to cloud completes and checks pass.

## Rollback / troubleshooting
- If cloud checks fail: inspect reverse proxy, firewall, and service state.
- If edge checks fail: re-run edge playbook and verify local services.
- If restore needed: use staged restore first, then live restore only with explicit operator approval.
