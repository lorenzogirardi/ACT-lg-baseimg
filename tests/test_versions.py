"""versions.yaml is the single source of truth for every pinned version: these tests keep it parseable and
keep the build args the Dockerfiles and workflows depend on stable."""
import re
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))
import versions  # noqa: E402


def test_repository_versions_file_is_complete_and_pinned():
    values = versions.load()
    for key in ("debian", "python", "node", "go"):
        assert key in values
    # python, node and go are exact versions (major.minor.patch), never a range or `latest`
    for key in ("python", "node", "go"):
        assert re.fullmatch(r"\d+\.\d+\.\d+", values[key]), f"{key} must be pinned to an exact version"
    # debian is a dated snapshot tag, not the floating `trixie-slim`
    assert re.fullmatch(r"[a-z]+-\d{8}-slim", values["debian"])


def test_every_version_has_a_renovate_hint():
    text = (versions.ROOT / "versions.yaml").read_text().splitlines()
    for number, line in enumerate(text):
        if re.match(r"^(debian|python|node|go):", line):
            assert text[number - 1].startswith("# renovate:"), f"line {number + 1}: Renovate cannot update {line.split(':')[0]}"


def test_build_args_derived_from_versions():
    args = versions.build_args({"debian": "trixie-20260101-slim", "python": "3.15.2", "node": "24.22.3", "go": "1.27.4"})
    assert args["PYTHON_MINOR"] == "3.15"
    assert args["NODE_MAJOR"] == "24"
    assert args["GO_MINOR"] == "1.27"
    assert args["DEBIAN_TAG"] == "trixie-20260101-slim"


def test_missing_key_is_an_error(tmp_path):
    broken = tmp_path / "versions.yaml"
    broken.write_text("debian: trixie-20260101-slim\npython: 3.15.2\n")
    with pytest.raises(ValueError, match="missing"):
        versions.load(broken)


def test_malformed_line_is_an_error(tmp_path):
    broken = tmp_path / "versions.yaml"
    broken.write_text("debian trixie\n")
    with pytest.raises(ValueError, match="not a `key: value` line"):
        versions.load(broken)
