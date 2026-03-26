# Title
CI linting and validation improvements

## Problem
Current CI performs baseline checks, but pilot maturity requires broader linting and infrastructure syntax validation once tool availability is standardized.

## Desired outcome
CI pipeline that catches script/tooling/infrastructure regressions early and produces actionable feedback.

## Acceptance criteria
- Add shellcheck job (or equivalent) for scripts.
- Add Terraform fmt/validate stage when Terraform is available in CI image.
- Add Ansible syntax-check stage with documented inventory strategy.
- Expand Python test coverage for negative-path utility behavior.
- PR template updated with required validation checklist.

## Dependencies
- CI runner image/toolchain decisions.
- Stable sample fixtures for test expansion.

## Notes/Risks
- Tool availability mismatches between local and CI can cause noisy failures.
- Overly strict gates may block quick pilot iteration if not tuned.
