from __future__ import annotations

import subprocess
from pathlib import Path


def run_validator(config_path: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["bash", "scripts/validate-config.sh", "--config", str(config_path)],
        check=False,
        capture_output=True,
        text=True,
    )


def test_validate_config_passes_for_valid_config(tmp_path: Path) -> None:
    cfg = tmp_path / "pilot.yaml"
    cfg.write_text(
        """
pilot:
  environment: dev
  tak_fqdn: tak.lab.local
  cloud:
    provider: digitalocean
    region: nyc3
  edge:
    hostname: edge-dev-01
    mode: degraded-ready
backup:
  enabled: true
  destination: /var/backups/tak
""".strip()
        + "\n",
        encoding="utf-8",
    )

    result = run_validator(cfg)
    assert result.returncode == 0
    assert "Config validation passed" in result.stdout


def test_validate_config_fails_for_missing_required_key(tmp_path: Path) -> None:
    cfg = tmp_path / "pilot.yaml"
    cfg.write_text(
        """
pilot:
  environment: dev
backup:
  enabled: true
  destination: /var/backups/tak
""".strip()
        + "\n",
        encoding="utf-8",
    )

    result = run_validator(cfg)
    assert result.returncode != 0
