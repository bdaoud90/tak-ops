# Security and Data Handling

This page states **what must never be placed in this repository** and **what
must be redacted before sharing with an external partner** (e.g., Buraq AI).
It complements [`.github/SECURITY.md`](../.github/SECURITY.md) and the
[threat model](./threat-model.md).

## Do not commit (hard rules)

Never add to version control:

- Secrets/credentials: API tokens, OAuth client IDs/secrets, passwords,
  `DO_TOKEN`, SSH key fingerprints, `.env` files with real values.
- Certificates and key material: `*.pem`, `*.key`, `*.jks`, keystores,
  truststores, CA private material.
- Terraform state: `*.tfstate*`, `.terraform/`, lock files (state can contain
  resolved secrets and infrastructure detail).
- Private operational data: precise sensitive coordinates, private server
  FQDNs/IPs, internal hostnames, field identities, source identities,
  detailed field procedures, vendor-specific or licensed TAK artifacts.
- Raw sensitive media: incident images/video, especially anything that could
  identify individuals or precise sensitive locations.

### What enforces this today

- **`.gitignore`** excludes `.env`, `.env.*` (except `.env.example`),
  `secrets/`, `**/.terraform/`, `*.tfstate*`, `*.retry`, logs, and artifacts.
- **`.env.example` / `*.tfvars.example`** carry only `replace_me`-style
  placeholders — never real values.
- **`scripts/package-operator-bundle.sh`** builds a sanitized operator bundle
  and actively rejects secret/state/binary patterns (`.env*`, `secret*`,
  `private*`, `state*`, `terraform.tfstate*`, `.terraform`, `takserver*`,
  `*.pem`, `*.key`, ...) and path traversal.
- **CI** (`.github/workflows/ci.yml`) runs without any secrets.

## Redact before partner review

Before sharing a branch, bundle, or export externally, confirm:

- No real endpoint URLs, tenant IDs, or account identifiers in docs or
  examples (use placeholders like `<tak-fqdn-or-ip>` / `replace_me`).
- No real coordinates, locality names tied to sensitive sites, or source/
  field identities in any committed sample data.
- `.github/SECURITY.md` contact is set to your real security inbox **only in
  your private deployment**, not in a shared/public copy
  (it ships as `security@example.com` by design).
- ACLED and any other credentials live only in untracked `.env` files.
- Any media shared for an AI-integration discussion is **synthetic or fully
  cleared**, never raw sensitive field media.

## Data-handling principles

- **Least exposure in public outputs.** The public incident tracker payload
  (see [schema/incidents-json.md](./schema/incidents-json.md)) must contain
  only what is intended for public consumption — no internal-only attributes,
  no exact sensitive coordinates unless explicitly approved.
- **Precision control.** Treat location precision as a first-class field.
  Default to coarsened/withheld precision for sensitive sites.
- **Human review before operational use.** AI-derived or automated
  classifications are advisory until an operator approves them
  (see [buraq-ai-integration.md §5](./buraq-ai-integration.md#5-security-boundaries)).
- **Separation of concerns.** Detection ≠ interpretation ≠ decision. Keep
  them distinct in data and in process.

## Prohibited capabilities

Regardless of partner or tooling: **no biometric identification, no face
recognition, no individual tracking, no targeting, no weaponization, and no
personal identity inference** anywhere in this system or any proposed
integration.

## If you find a leak

If a secret or sensitive value was committed: treat it as compromised, rotate
it immediately, remove it from history per your security process, and report
privately per [`.github/SECURITY.md`](../.github/SECURITY.md). Do not open a
public issue.
