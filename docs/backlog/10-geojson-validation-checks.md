# Title
GeoJSON validation checks

## Problem
Basic GeoJSON validator exists, but pilot workflows need explicit validation coverage and known limitations documented.

## Desired outcome
A dependable validation gate before publishing/using GeoJSON outputs.

## Acceptance criteria
- Validator enforces `FeatureCollection` root.
- Validator enforces feature type and point geometry constraints.
- Validator checks coordinate structure and reports indexed failures.
- Success/failure examples documented.
- Tests include at least one invalid sample case.

## Dependencies
- CSV-to-GeoJSON converter behavior finalized.
- Agreed minimum schema for pilot maps.

## Notes/Risks
- Validator is intentionally minimal and may not cover all GeoJSON extensions.
- Overly strict rules can reject legitimate future geometry types.
