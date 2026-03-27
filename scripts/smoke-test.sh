#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: smoke-test.sh [--target HOST] [--port PORT] [--timeout SEC] [--insecure] [--skip-https] [--expect-code CODE] [--help]

Perform layered smoke checks for endpoint reachability:
1) TCP connectivity to target:port
2) Optional HTTPS check to https://target:port

Options:
  --target HOST       Hostname or IP (fallback: TAK_FQDN env)
  --port PORT         TCP/HTTPS port (default: TAK_SMOKE_TEST_PORT or 443)
  --timeout SEC       Check timeout in seconds (default: TAK_SMOKE_TEST_TIMEOUT or 15)
  --insecure          Allow insecure TLS verification (pilot use only)
  --skip-https        Skip HTTPS HTTP-status validation (TCP-only check)
  --expect-code CODE  Expected HTTP status code for HTTPS check (default: any 2xx/3xx)
  -h, --help          Show this help message
USAGE
}

TARGET="${TAK_FQDN:-}"
PORT="${TAK_SMOKE_TEST_PORT:-443}"
TIMEOUT="${TAK_SMOKE_TEST_TIMEOUT:-15}"
SKIP_HTTPS=false
EXPECT_CODE=""
CURL_TLS_ARGS=(--fail --show-error --silent)

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      [[ $# -ge 2 ]] || { echo "ERROR: --target requires a value" >&2; exit 2; }
      TARGET="$2"; shift 2 ;;
    --port)
      [[ $# -ge 2 ]] || { echo "ERROR: --port requires a value" >&2; exit 2; }
      PORT="$2"; shift 2 ;;
    --timeout)
      [[ $# -ge 2 ]] || { echo "ERROR: --timeout requires a value" >&2; exit 2; }
      TIMEOUT="$2"; shift 2 ;;
    --insecure)
      CURL_TLS_ARGS+=(--insecure); shift ;;
    --skip-https)
      SKIP_HTTPS=true; shift ;;
    --expect-code)
      [[ $# -ge 2 ]] || { echo "ERROR: --expect-code requires a value" >&2; exit 2; }
      EXPECT_CODE="$2"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "ERROR: Unknown argument: $1" >&2
      usage >&2
      exit 2 ;;
  esac
done

command -v curl >/dev/null 2>&1 || { echo "ERROR: curl is required" >&2; exit 1; }
command -v timeout >/dev/null 2>&1 || { echo "ERROR: timeout command is required" >&2; exit 1; }
[[ -n "$TARGET" ]] || { echo "ERROR: target is required (use --target or TAK_FQDN)" >&2; exit 1; }
[[ "$TIMEOUT" =~ ^[0-9]+$ ]] || { echo "ERROR: timeout must be integer seconds" >&2; exit 1; }
[[ "$PORT" =~ ^[0-9]+$ ]] || { echo "ERROR: port must be numeric" >&2; exit 1; }
if [[ -n "$EXPECT_CODE" && ! "$EXPECT_CODE" =~ ^[0-9]{3}$ ]]; then
  echo "ERROR: --expect-code must be a 3-digit HTTP status code" >&2
  exit 1
fi

echo "[smoke-test] tcp check ${TARGET}:${PORT} (timeout=${TIMEOUT}s)"
if timeout "$TIMEOUT" bash -c "</dev/tcp/${TARGET}/${PORT}"; then
  echo "[smoke-test] TCP PASS"
else
  echo "[smoke-test] TCP FAIL: cannot reach ${TARGET}:${PORT}" >&2
  exit 1
fi

if [[ "$SKIP_HTTPS" == "true" ]]; then
  echo "[smoke-test] HTTPS check skipped by --skip-https"
  exit 0
fi

URL="https://${TARGET}:${PORT}"
echo "[smoke-test] https check ${URL}"
HTTP_CODE="$(curl "${CURL_TLS_ARGS[@]}" --max-time "$TIMEOUT" -o /dev/null -w '%{http_code}' "$URL")"

if [[ -n "$EXPECT_CODE" ]]; then
  if [[ "$HTTP_CODE" == "$EXPECT_CODE" ]]; then
    echo "[smoke-test] HTTPS PASS (status=${HTTP_CODE})"
  else
    echo "[smoke-test] HTTPS FAIL: expected ${EXPECT_CODE}, got ${HTTP_CODE}" >&2
    exit 1
  fi
else
  if [[ "$HTTP_CODE" =~ ^[23][0-9]{2}$ ]]; then
    echo "[smoke-test] HTTPS PASS (status=${HTTP_CODE})"
  else
    echo "[smoke-test] HTTPS FAIL: expected 2xx/3xx, got ${HTTP_CODE}" >&2
    exit 1
  fi
fi
