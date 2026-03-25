#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: smoke-test.sh [--target HOST] [--timeout SEC] [--insecure] [--help]

Perform a simple HTTPS smoke test for TAK endpoint reachability.

Options:
  --target HOST   Hostname or IP (fallback: TAK_FQDN env)
  --timeout SEC   Curl timeout in seconds (default: TAK_SMOKE_TEST_TIMEOUT or 15)
  --insecure      Allow insecure TLS verification (for pilot only)
  -h, --help      Show this help message
USAGE
}

TARGET="${TAK_FQDN:-}"
TIMEOUT="${TAK_SMOKE_TEST_TIMEOUT:-15}"
CURL_TLS_ARGS=(--fail --show-error --silent)

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      [[ $# -ge 2 ]] || { echo "ERROR: --target requires a value" >&2; exit 2; }
      TARGET="$2"
      shift 2
      ;;
    --timeout)
      [[ $# -ge 2 ]] || { echo "ERROR: --timeout requires a value" >&2; exit 2; }
      TIMEOUT="$2"
      shift 2
      ;;
    --insecure)
      CURL_TLS_ARGS+=(--insecure)
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

command -v curl >/dev/null 2>&1 || { echo "ERROR: curl is required" >&2; exit 1; }
[[ -n "$TARGET" ]] || { echo "ERROR: target is required (use --target or TAK_FQDN)" >&2; exit 1; }
[[ "$TIMEOUT" =~ ^[0-9]+$ ]] || { echo "ERROR: timeout must be integer seconds" >&2; exit 1; }

echo "[smoke-test] testing https://${TARGET} (timeout=${TIMEOUT}s)"
if curl "${CURL_TLS_ARGS[@]}" --max-time "$TIMEOUT" "https://${TARGET}" >/dev/null; then
  echo "[smoke-test] PASS"
else
  echo "[smoke-test] FAIL: endpoint unreachable or unhealthy" >&2
  exit 1
fi
