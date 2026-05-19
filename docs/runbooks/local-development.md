# Runbook: Local Development (Overview)

A partner-safe entry point for local development. This page is an **index**;
the authoritative steps live in the existing runbooks linked below (kept as-is
to avoid breaking references).

## Goal

Validate the repository locally without provisioning any cloud infrastructure
and without any real secrets.

## Minimal local loop

```bash
./scripts/create-env.sh        # create local .env from template (no real values needed for lint/test)
./scripts/validate-config.sh   # validate config/pilot.yaml
make lint                      # bash -n + python compileall + config validation
make test                      # pytest (tooling transforms / geo pipeline)
```

`make init` creates a `.venv` and installs `pytest`, `PyYAML`, and `ansible`
for fuller local validation. `make terraform-validate` and `make ansible-lint`
require `terraform` / `ansible` on PATH.

## Python tooling (no external calls needed for tests)

- `tooling/acled/` — ACLED OAuth sync + normalization (network only at runtime)
- `tooling/geo/` — CSV→GeoJSON conversion and GeoJSON validation
- `tooling/notion/` — report export/normalization

## Authoritative references

- [Quickstart: Download, Install, Deploy](./quickstart-download-install-deploy.md)
- [ACLED Ingestion](./acled-ingestion.md)
- [Smoke Test](./smoke-test.md)
- [Layer Schema](../data/layer-schema.md)
- [Documentation Index](../README.md)

> No secrets are required for `make lint` / `make test`. Never put real
> credentials in a committed file — see
> [security-and-data-handling.md](../security-and-data-handling.md).
