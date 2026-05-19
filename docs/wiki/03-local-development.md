# 03 · Local Development

Minimal local loop (no cloud, no real secrets):

```bash
./scripts/create-env.sh
./scripts/validate-config.sh
make lint     # bash -n + python compileall + config validation
make test     # pytest
```

- `make init` creates `.venv` and installs `pytest`, `PyYAML`, `ansible`.
- `make terraform-validate` / `make ansible-lint` need `terraform` /
  `ansible` on PATH.
- CI mirrors these checks and uses **no secrets**.

Full details: [runbooks/local-development.md](../runbooks/local-development.md).
Security rules: [security-and-data-handling.md](../security-and-data-handling.md).
