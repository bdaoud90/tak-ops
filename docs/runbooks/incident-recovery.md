# Runbook: Incident Recovery

1. Isolate impacted host and preserve evidence.
2. Identify latest verified backup + checksum.
3. Perform staged restore (default behavior of `scripts/restore.sh`).
4. Validate restored content and service expectations.
5. If approved, run live restore with explicit `--live-restore`.
6. Run post-install validation and layered smoke tests.
7. Document incident timeline and lessons learned.
