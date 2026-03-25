#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: bootstrap-edge.sh [--inventory PATH] [--playbook PATH] [--help]

Run edge-node Ansible bootstrap.

Options:
  --inventory PATH  Ansible inventory file (default: infra/ansible/inventories/dev/hosts.yml)
  --playbook PATH   Playbook path (default: infra/ansible/playbooks/edge-node.yml)
  -h, --help        Show this help message
USAGE
}

INVENTORY="infra/ansible/inventories/dev/hosts.yml"
PLAYBOOK="infra/ansible/playbooks/edge-node.yml"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --inventory)
      [[ $# -ge 2 ]] || { echo "ERROR: --inventory requires a value" >&2; exit 2; }
      INVENTORY="$2"
      shift 2
      ;;
    --playbook)
      [[ $# -ge 2 ]] || { echo "ERROR: --playbook requires a value" >&2; exit 2; }
      PLAYBOOK="$2"
      shift 2
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

command -v ansible-playbook >/dev/null 2>&1 || { echo "ERROR: ansible-playbook not found" >&2; exit 1; }
[[ -f "$INVENTORY" ]] || { echo "ERROR: Inventory not found: $INVENTORY" >&2; exit 1; }
[[ -f "$PLAYBOOK" ]] || { echo "ERROR: Playbook not found: $PLAYBOOK" >&2; exit 1; }

echo "[bootstrap-edge] inventory=$INVENTORY playbook=$PLAYBOOK"
ansible-playbook -i "$INVENTORY" "$PLAYBOOK"
