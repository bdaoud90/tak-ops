from __future__ import annotations

import subprocess
from pathlib import Path


def test_backup_creates_archive_and_checksum(tmp_path: Path) -> None:
    src = tmp_path / "src"
    src.mkdir()
    (src / "demo.txt").write_text("hello", encoding="utf-8")
    out = tmp_path / "out"

    result = subprocess.run(
        ["bash", "scripts/backup.sh", "--source", str(src), "--dest", str(out), "--name", "demo"],
        check=False,
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0
    archives = sorted(out.glob("demo-*.tar.gz"))
    checksums = sorted(out.glob("demo-*.tar.gz.sha256"))
    assert archives
    assert checksums


def test_restore_requires_checksum_unless_skipped(tmp_path: Path) -> None:
    archive = tmp_path / "fake.tar.gz"
    archive.write_bytes(b"not-a-real-archive")

    result = subprocess.run(
        ["bash", "scripts/restore.sh", "--archive", str(archive)],
        check=False,
        capture_output=True,
        text=True,
    )
    assert result.returncode != 0
    assert "Checksum file missing" in result.stderr
