# Title
CSV to GeoJSON converter

## Problem
CSV conversion utility exists, but operators need confidence around coordinate parsing, property mapping, and predictable output shape.

## Desired outcome
A stable converter with clear input constraints and failure messaging.

## Acceptance criteria
- Utility fails fast on missing `lat`/`lon` columns.
- Invalid coordinate values produce actionable errors.
- Generated GeoJSON is deterministic and pretty-printed.
- Example input/output included in docs or test fixtures.
- Pipeline integration step documented.

## Dependencies
- Normalized CSV schema agreement.
- GeoJSON consumer requirements (QGIS/workflow).

## Notes/Risks
- Coordinate order mistakes can silently misplace points.
- Large files may require future streaming/performance tuning.
