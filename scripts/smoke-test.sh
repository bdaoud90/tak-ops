#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: smoke-test.sh [options]

Layered pilot smoke validation for TAK environment.

Options:
  --target HOST              Target hostname/IP (fallback: TAK_FQDN)
  --proxy-port PORT          Reverse-proxy port (default: 443)
  --service-port PORT        Backend service port to probe (default: TAK_SERVICE_PORT or 8089)
  --timeout SEC              Timeout per check (default: 10)
  --health-url URL           Optional HTTPS/HTTP health endpoint
  --process-check CMD        Optional remote process check command executed over SSH
  --ssh-user USER            SSH user for process check
  --insecure                 Disable TLS verification for pilot testing
  -h, --help                 Show help
USAGE
}

TARGET="${TAK_FQDN:-}"
PROXY_PORT=443
SERVICE_PORT="${TAK_SERVICE_PORT:-8089}"
TIMEOUT=10
HEALTH_URL=""
PROCESS_CHECK=""
SSH_USER=""
CURL_FLAGS=(--silent --show-error --fail)

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    --proxy-port) PROXY_PORT="$2"; shift 2 ;;
    --service-port) SERVICE_PORT="$2"; shift 2 ;;
    --timeout) TIMEOUT="$2"; shift 2 ;;
    --health-url) HEALTH_URL="$2"; shift 2 ;;
    --process-check) PROCESS_CHECK="$2"; shift 2 ;;
    --ssh-user) SSH_USER="$2"; shift 2 ;;
    --insecure) CURL_FLAGS+=(--insecure); shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

command -v curl >/dev/null 2>&1 || { echo "ERROR: curl is required" >&2; exit 1; }
command -v nc >/dev/null 2>&1 || { echo "ERROR: nc is required" >&2; exit 1; }

[[ -n "$TARGET" ]] || { echo "ERROR: --target or TAK_FQDN required" >&2; exit 1; }
[[ "$PROXY_PORT" =~ ^[0-9]+$ ]] || { echo "ERROR: invalid --proxy-port" >&2; exit 1; }
[[ "$SERVICE_PORT" =~ ^[0-9]+$ ]] || { echo "ERROR: invalid --service-port" >&2; exit 1; }
[[ "$TIMEOUT" =~ ^[0-9]+$ ]] || { echo "ERROR: invalid --timeout" >&2; exit 1; }

pass() { echo "[PASS] $1"; }
fail() { echo "[FAIL] $1" >&2; return 1; }

# Layer 1: network reachability to proxy port
if nc -z -w "$TIMEOUT" "$TARGET" "$PROXY_PORT"; then
  pass "Network reachability to ${TARGET}:${PROXY_PORT}"
else
  fail "Network reachability to ${TARGET}:${PROXY_PORT}"; exit 1
fi

# Layer 2: TLS/reverse proxy endpoint
if curl "${CURL_FLAGS[@]}" --max-time "$TIMEOUT" "https://${TARGET}:${PROXY_PORT}/" >/dev/null; then
  pass "Reverse proxy/TLS endpoint reachable"
else
  fail "Reverse proxy/TLS endpoint check failed"; exit 1
fi

# Layer 3: backend service port reachability
if nc -z -w "$TIMEOUT" "$TARGET" "$SERVICE_PORT"; then
  pass "Configured service port reachable (${SERVICE_PORT})"
else
  fail "Configured service port unreachable (${SERVICE_PORT})"
fi

# Layer 4a: optional health endpoint
if [[ -n "$HEALTH_URL" ]]; then
  if curl "${CURL_FLAGS[@]}" --max-time "$TIMEOUT" "$HEALTH_URL" >/dev/null; then
    pass "Health endpoint check passed (${HEALTH_URL})"
  else
    fail "Health endpoint check failed (${HEALTH_URL})"
  fi
fi

# Layer 4b: optional process check via SSH
if [[ -n "$PROCESS_CHECK" ]]; then
  command -v ssh >/dev/null 2>&1 || { echo "ERROR: ssh required for --process-check" >&2; exit 1; }
  [[ -n "$SSH_USER" ]] || { echo "ERROR: --ssh-user is required with --process-check" >&2; exit 1; }
  if ssh -o BatchMode=yes -o ConnectTimeout="$TIMEOUT" "${SSH_USER}@${TARGET}" "$PROCESS_CHECK"; then
    pass "Remote process check command succeeded"
  else
    fail "Remote process check command failed"
  fi
fi

echo "[smoke-test] Completed layered checks"
