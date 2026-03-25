# Title
Pilot deployment checklist

## Problem
Checklist exists but should be operationalized with ownership, evidence capture, and gate criteria.

## Desired outcome
A deployment checklist that can serve as a formal go/no-go artifact.

## Acceptance criteria
- Checklist includes owner and timestamp fields.
- Every item maps to evidence artifact (log, screenshot, command output, ticket).
- Go/no-go section includes explicit approval sign-off.
- Checklist references backup and outage drill completion.
- Checklist is linked from README and first-deploy runbook.

## Dependencies
- Deployment plan and runbooks finalized.
- Team agreement on approval workflow.

## Notes/Risks
- Incomplete evidence trails reduce auditability.
- Checklist sprawl can reduce operator adoption if too complex.
