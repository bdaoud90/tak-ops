# Codex Prompt: Correct TAK Ops Repo Drift, Capture Test-Environment Truth, and Package the Repo for Fast Install/Deploy

You are working in the `bdaoud90/tak-ops` repository.

Your task is to perform a comprehensive, future-proof repository update that does **all** of the following:

1. Correct documentation drift and inaccuracies introduced during live testing.
2. Capture the real operational state of the TAK test environment as it exists now.
3. Add missing runbooks and known-issue documentation for client onboarding, Android trust/cert behavior, ACLED ingestion, overlays/layers, and operational data workflows.
4. Reorganize the repo so a new operator can clone/download it and get to a usable pilot deployment quickly.
5. Add packaging/bootstrap/install/deploy guidance and supporting scripts where appropriate.
6. Preserve clear automation boundaries for proprietary/restricted TAK components.

This task is not only a doc cleanup. It is a repo-hardening and operator-packaging pass.

Do not make speculative runtime changes to the live TAK service configuration unless necessary to support install/deploy tooling or documentation accuracy. Prefer safe, additive changes. If scripts are added, keep them conservative, explicit, and well-commented.

---

## High-level objective

Transform the repository from a strong troubleshooting checkpoint into a **downloadable, operator-ready TAK pilot package** that accurately reflects the tested environment and provides:

- fast start instructions
- realistic client onboarding instructions
- ACLED ingestion setup
- layer/overlay workflow guidance
- packaging/bootstrap helpers
- repeatable deployment instructions

The end state should let a future operator answer these questions quickly:

- What has actually been tested and verified?
- What is still unresolved?
- What is the fastest known-good install/deploy path?
- How do I onboard WinTAK?
- Why is ATAK/CivTAK still tricky, and what exact constraints were observed?
- How do I begin populating the TAK server with layers, incidents, medical points, supply nodes, and external intelligence feeds like ACLED?

---

## Current verified operational facts that documentation must reflect

### Host / deployment reality
- Live test environment is a DigitalOcean droplet running **Ubuntu 24.04**.
- TAK 5.7 package deployment under `/opt/tak`.
- `/etc/init.d/takserver` is a wrapper/orchestrator for multiple services:
  - `takserver-config`
  - `takserver-messaging`
  - `takserver-api`
  - `takserver-plugins`
  - `takserver-retention`
- The wrapper/service status can be misleading; real health must be verified per service and via socket bindings.

### PostgreSQL facts
- PostgreSQL 15 cluster is now online.
- `pg_lsclusters` is the real source of truth for cluster state; wrapper/systemd alone can mislead.
- Memory tuning was required earlier on the small droplet.
- `cot` database exists and is reachable.
- `martiuser` can connect successfully to `cot`.
- During troubleshooting, `martiuser` was elevated to `SUPERUSER` to eliminate metadata/pool-size ambiguity; this should be documented as temporary and a hardening backlog item.

### Cert / PKI facts
- Earlier failures were caused by stale CA artifacts, mismatched passwords, and dropped environment variables during cert generation.
- Clean cert regeneration eventually succeeded.
- Cert artifacts exist under `/opt/tak/certs/files/`.
- Verified artifacts include at least:
  - `takserver.jks`
  - `takserver.p12`
  - `truststore-root.jks`
  - `fed-truststore.jks`
  - `admin.p12`
  - `user.p12`
- `keytool -list -keystore /opt/tak/certs/files/takserver.jks` succeeds with the actual configured password.

### Current listener / runtime facts
- Confirmed listeners up in known-good state:
  - `8443`
  - `8446`
  - `8089`
- API log shows Tomcat initialized on `8443`, `8444`, `8446`.
- Messaging log shows normal startup with a non-blocking TLS CRL/OCSP warning.
- Retention log shows normal startup and DB pool startup.

### WinTAK reality (important correction)
- WinTAK has been successfully connected.
- The **actual tested working path** used:
  - pre-issued `admin.p12`
  - manual certificate installation/import flow in the client context
  - connection path that ended up succeeding on **`8089` with SSL/TLS**
- This means the repo should **not** continue to present `8446` as the primary tested WinTAK operational connection path.
- `8446` should instead be described more carefully as a cert-auth/API-related endpoint observed during service startup, but not the primary validated WinTAK operational path.

### WinTAK UI facts
- WinTAK onboarding was not button-centric; connection management is configuration/state-driven.
- A server must exist in the connection manager before it appears in feed workflows.
- When using a pre-issued client certificate, client enrollment must be disabled; otherwise the UI/flow becomes misleading.

### Android / ATAK / CivTAK reality (important open issue)
- Android onboarding remains partially unresolved / environment-fragile.
- The major constraint discovered:
  - `Use default SSL/TLS Certificates` can help with trust behavior but prevents manual client certificate import.
- ATAK/CivTAK file picker behavior was inconsistent:
  - `.p12` showed up reliably
  - `.pem` often did not show up in trust store import workflow
  - `.crt` / `.cer` is more reliable for trust-store import
- ATAK/CivTAK appears to require both:
  - a trust anchor the app/device accepts
  - a client certificate (`user.p12`)
- This exact Android-mode conflict must be documented as a known issue and not hand-waved away.

### File export / SCP operational lesson
- Pulling cert artifacts directly from `/opt/tak/certs/files/` with `scp` failed because files were root-owned / unreadable by `ubuntu`.
- Practical workaround was to stage exportable client files into `/home/ubuntu/` before copying.
- This should be documented explicitly in client onboarding/export guidance.

### ACLED / data population state
- ACLED API ingestion has been designed conceptually but not yet committed as tooling.
- The desired first implementation is:
  - ACLED OAuth auth
  - filtered fetch
  - normalization
  - GeoJSON export for WinTAK/TAK overlays
- Longer-term path includes tactical filtering and later CoT emission, but the first repo addition should focus on:
  - pull script
  - env example
  - runbook
  - output conventions

### Layer / data population direction
- The next operational phase is not more server debugging.
- It is:
  - overlays
  - markers
  - incident layers
  - medical locations
  - supply nodes
  - village / AOP polygons
  - observation points
  - external intelligence overlay ingestion
- The repo should gain explicit guidance for the layer schema and recommended data categories.

---

## Repository problems to correct

### Documentation drift / inaccuracies
Correct the following:

1. **Ubuntu version inconsistency**
   - Some existing repo text still references Ubuntu 22.04 baseline while live operational documentation references Ubuntu 24.04.
   - Normalize wording so the repo clearly distinguishes:
     - original scaffold baseline assumptions
     - current validated live test environment

2. **WinTAK client port guidance drift**
   - Update docs that currently frame `8446` as the primary client onboarding path.
   - Replace with the actually validated WinTAK path on `8089` using SSL/TLS and pre-issued cert workflow.

3. **Android/ATAK gaps**
   - Add explicit, sober documentation of the current Android trust/cert conflict.
   - Do not pretend Android onboarding is fully solved if it is not.

4. **Client export guidance gap**
   - Add practical documentation for staging `.p12` files into `/home/ubuntu/` before SCP/export.

5. **Missing data-ingestion and layer docs**
   - Add ACLED ingestion runbook and tooling.
   - Add layer schema / overlay workflow documentation.

---

## Concrete changes to make

### 1. Update `README.md`

Revise README to be the clean operational landing page.

It should include:
- a clear current-state section for the validated Ubuntu 24.04 test environment
- the multi-service architecture note
- the verified listeners (`8443`, `8446`, `8089`)
- a concise “tested client status” section:
  - WinTAK validated
  - Android/CivTAK still partially unresolved due to trust/client-cert import interaction
- a short “what this repo does now” section:
  - install/deploy scaffold
  - operator runbooks
  - data/overlay tooling
- a short “fast path” section for new operators:
  - clone
  - bootstrap env
  - provision infra
  - configure host
  - manually install TAK artifacts
  - verify listeners
  - onboard WinTAK
- a clear note that proprietary/restricted TAK binaries are not vendored

The README should become the **best 5-minute orientation doc**.

---

### 2. Update `docs/runbooks/tak-demo-mvp.md`

Revise the demo runbook to reflect the actual tested state.

Changes required:
- correct the WinTAK primary tested path from `8446` to `8089`
- keep `8443` and `8446` documented, but distinguish their roles more carefully
- add a note that WinTAK onboarding is configuration/state-driven, not always button-driven
- explicitly document that pre-issued cert workflows must disable enrollment in the client
- add a separate Android section with current known constraints rather than overconfident steps
- include explicit server-side verification commands while attempting client connection:
  - `ss -ltnp`
  - `tail -f /opt/tak/logs/takserver-messaging.log`
  - `tail -f /opt/tak/logs/takserver-api.log`
- add a short “client export” subsection documenting:
  - copy from `/opt/tak/certs/files/` to `/home/ubuntu/`
  - then SCP from there

---

### 3. Update `docs/known-issues.md`

Add or expand entries for:

#### Android trust/client-cert mode conflict
Document:
- symptom
- why enabling default SSL/TLS certs blocks manual client cert import
- why this matters for mutual TLS setups
- mitigations / current recommended operator path

#### `.pem` not appearing in ATAK/CivTAK picker
Document:
- symptom
- likely cause (picker filtering / MIME or extension behavior)
- workaround: rename/use `.crt` or `.cer`

#### Pre-issued `.p12` plus enrollment conflict
Document:
- symptom
- cause
- fix: disable enrollment when using pre-issued certs

#### `scp` export failure from `/opt/tak/certs/files`
Document:
- symptom: permission denied
- cause: root-owned export path
- workaround: stage files into `/home/ubuntu/`

---

### 4. Update `docs/architecture/tak-service-map.md`

Preserve the current high-level service map but make it more operationally useful.

Add:
- a short section on how port bindings map to operator meaning
- a note that seeing `8446` bound does not automatically mean it is the primary validated operational client path
- a short client-path interpretation section:
  - `8089` = tested WinTAK TLS path
  - `8443` = HTTPS/API path
  - `8446` = cert-auth/API-related endpoint observed during service startup and still relevant, but not yet the single source of truth for fielded client guidance

---

### 5. Update `docs/timeline/tak-debugging-checkpoint-2026-04-12.md`

Revise the checkpoint doc so it reflects the actual next-step status:
- WinTAK validated on `8089`
- Android still open
- next transition is from platform bring-up into data population and overlays

Add a short “post-checkpoint developments” section rather than rewriting history.

---

### 6. Add `docs/runbooks/acled-ingestion.md`

Create a new detailed runbook that explains:

#### Objective
Use ACLED API to pull filtered event data into the TAK ecosystem.

#### Phase 1 implementation
- OAuth token retrieval
- incremental/rolling-window pull
- normalization
- GeoJSON export
- import into WinTAK as file overlay

#### Future phase
- AOP intersection filtering
- risk scoring
- later CoT emission for selected tactical events

#### Setup instructions
- venv creation
- dependencies
- `.env` usage
- first run
- expected outputs
- cron scheduling

#### Operational cautions
- ACLED is not a real-time field sensor
- use it as structured intelligence layer, not sole tactical source

#### Expected output files
- `acled_latest.json`
- `acled_latest.geojson`
- `acled_latest_summary.json`

---

### 7. Add ACLED tooling under `tooling/acled/`

Create:

#### `tooling/acled/acled_sync.py`
Implement the ACLED ingestion script consistent with the current desired approach:
- OAuth token request
- token caching/refresh if feasible
- rolling-window or last-run state
- filtered fetch
- normalization
- GeoJSON export
- summary export
- state file tracking

#### `tooling/acled/.env.example`
Include variables such as:
- `ACLED_USERNAME`
- `ACLED_PASSWORD`
- `ACLED_COUNTRY`
- `ACLED_ADMIN1`
- `ACLED_ADMIN2`
- `ACLED_LOOKBACK_DAYS`
- `ACLED_OUTPUT_DIR`
- `ACLED_STATE_DIR`
- `ACLED_INCLUDE_TYPES`
- `ACLED_INCLUDE_SUBTYPES`

#### Optional support files
If useful, add:
- `tooling/acled/requirements.txt`
- `tooling/acled/README.md`

Keep the script conservative, typed where practical, and operator-readable.

---

### 8. Add `docs/data/layer-schema.md`

Create a practical schema doc for how TAK/QGIS/overlay data should be structured.

Include recommended operational layers:
- Settler Attacks
- Medical Facilities
- Supply Nodes
- Villages / AOPs
- Observation Points
- Optional routes / movement corridors

For each, define:
- geometry type
- minimum attributes
- naming convention
- operational use

Suggested naming convention examples:
- `MED-QUSRA-01`
- `SUP-NABLUS-02`
- `INC-TURMUS-AYYA-014`
- `OBS-JVALLEY-005`

Explain the principle:
- QGIS = strategic authoring and analysis
- TAK = tactical visibility and shared situational awareness

---

### 9. Add packaging/bootstrap improvements so the repo is quick to download and use

This is important.

Create or improve scripts and docs so a new operator can get moving quickly.

Add a new top-level script, or improve existing scripts, so the repo has a clear bootstrap/install flow.

#### Add `scripts/bootstrap-ops-workstation.sh`
It should:
- verify basic dependencies (`python3`, `pip`, `git`, etc.)
- optionally check for `terraform`, `ansible`, `make`, `jq`, `curl`
- create local working dirs if needed
- create/copy env templates if missing
- print the next-step instructions
- not silently modify sensitive runtime configuration

#### Add `scripts/package-operator-bundle.sh`
Goal:
- package non-sensitive repo artifacts into a clean operator bundle for quick handoff
- exclude secrets and proprietary TAK binaries
- optionally produce a tarball/zip of docs, scripts, env examples, and tooling

Document clearly that this is an operator scaffold package, not a full TAK binary distribution.

#### Add `docs/runbooks/quickstart-download-install-deploy.md`
This should be the concise, future-proof install/deploy runbook.

It must cover:

##### Download / clone
- how to clone the repo
- where to start

##### Local bootstrap
- bootstrap script
- env creation
- validation commands

##### Infra deployment
- terraform path(s)
- init/plan/apply

##### Host configuration
- ansible playbook invocation
- inventory guidance

##### Manual TAK install boundary
- where the proprietary TAK artifacts must be placed
- what remains manual

##### Post-install verification
- `pg_lsclusters`
- `ss -ltnp`
- per-service logs
- keystore validation

##### Client onboarding
- link to the demo runbook

##### Data onboarding
- link to ACLED and layer docs

The intent is: a new operator should be able to get from clone to validated MVP deployment with minimal ambiguity.

---

### 10. Add tests where appropriate

If practical and low-risk, add minimal tests for:
- ACLED normalization / GeoJSON export logic
- bootstrap script shell syntax
- packaging script shell syntax

Do not overbuild a test framework just to satisfy the task. Keep it useful.

---

## Style requirements
- Use an operator-oriented, technically precise tone.
- Distinguish carefully between:
  - verified working state
  - currently unresolved/fragile behavior
  - future hardening items
- Do not overstate Android readiness.
- Do not pretend the repo fully automates proprietary TAK install.
- Keep docs structured and navigable.
- Prefer explicit command examples over vague prose.

---

## Deliverable requirements

Make the changes directly in the repo.

At the end, provide a concise implementation summary including:
- files changed
- new files added
- doc corrections made
- scripts added/updated
- any assumptions made
- any intentionally deferred items

Also ensure the repository remains coherent for a future operator who downloads it fresh.
