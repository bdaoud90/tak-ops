# Title
Notion export utility

## Problem
Notion export helper exists but needs defined schema assumptions, operator examples, and validation expectations for pilot data quality.

## Desired outcome
A documented and tested export flow producing deterministic CSV outputs for downstream tooling.

## Acceptance criteria
- Input format assumptions are documented (NDJSON fields).
- CLI examples added to docs.
- Malformed line behavior (`--strict` vs non-strict) is documented.
- Deterministic sorting verified in test fixture.
- Output schema matches downstream normalizer expectations.

## Dependencies
- Pilot reporting field definitions.
- Sample anonymized export data for testing.

## Notes/Risks
- Schema drift from source system can break pipeline unexpectedly.
- Sensitive report data must be sanitized in test fixtures.
