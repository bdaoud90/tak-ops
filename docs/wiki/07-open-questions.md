# 07 · Open Questions

## For Buraq AI

See the full list in
[buraq-ai-integration.md §6](../buraq-ai-integration.md#6-questions-for-buraq-ai).
Highlights:

- Supported input formats; can they handle still images, video, drone,
  body-camera, phone footage, satellite imagery?
- Structured JSON output conforming to the proposed contract (§4)?
- Offline / edge-node operation; hardware requirements?
- Arabic / Hebrew / English text-in-image handling?
- Confidence scoring; detection vs. interpretation separation?
- Local processing without cloud upload; logging retention; training-data use?

## For PALSHIELD (internal)

- Which future layers come next (medical, supply, routes, AOPs) and on what
  cadence?
- Where will a media-intake pipeline live (this repo vs. a new service)?
- Approval workflow and owner for releasing precise locations publicly.
- Production hardening items from the backlog to prioritize before scale-up
  (e.g., CRL/OCSP, Android cert onboarding SOP — see
  [known-issues.md](../known-issues.md)).

## Documentation follow-ups

- Confirm the exact public `incidents.json` envelope/lookup-table layout with
  the owners of the separate public tracker (this repo documents the
  *contract*, not the file).
- Proposed (not performed) renames — see the PR summary.
