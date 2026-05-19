# 06 · Security & Redaction Rules

Full detail: [security-and-data-handling.md](../security-and-data-handling.md).

## Never commit

Secrets/tokens, certs/keys (`*.pem`, `*.key`, keystores), Terraform state,
precise sensitive coordinates, private FQDNs/IPs, field/source identities,
detailed field procedures, licensed TAK artifacts, raw sensitive media.

## Enforced by

- `.gitignore` (`.env*` except `.env.example`, `secrets/`, `.terraform/`,
  `*.tfstate*`, logs, artifacts).
- `*.example` files carry placeholders only.
- `scripts/package-operator-bundle.sh` rejects secret/state/binary patterns.
- CI runs with **no secrets**.

## Redact before sharing externally

Real endpoints/IDs, real coordinates/localities tied to sensitive sites,
source/field identities, real security contact (ships as
`security@example.com` by design). Any media used for AI discussions must be
synthetic or fully cleared.

## Prohibited capabilities

No biometric ID, face recognition, individual tracking, targeting,
weaponization, or identity inference — anywhere, including proposed
integrations.
