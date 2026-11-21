#!/usr/bin/env python3
"""Read versions.yaml and print the values the build needs.

versions.yaml is a flat `key: value` file with `#` comments, so no YAML library is needed (CI and the
agents run this with a bare Python).

    scripts/versions.py                 KEY=value lines (DEBIAN_TAG, PYTHON_VERSION, ...), for $GITHUB_OUTPUT or eval
    scripts/versions.py --get python    a single value
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REQUIRED = {"debian": "DEBIAN_TAG", "python": "PYTHON_VERSION", "node": "NODE_VERSION", "go": "GO_VERSION"}
LINE = re.compile(r"^([a-z_]+):\s*(\S+)\s*(?:#.*)?$")


def load(path: Path = ROOT / "versions.yaml") -> dict:
    """Return {key: value}. Raises ValueError when a required key is missing or a line is malformed."""
    values = {}
    for number, raw in enumerate(path.read_text().splitlines(), start=1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        match = LINE.match(line)
        if not match:
            raise ValueError(f"{path.name}:{number}: not a `key: value` line: {raw!r}")
        values[match.group(1)] = match.group(2)
    missing = sorted(set(REQUIRED) - set(values))
    if missing:
        raise ValueError(f"{path.name}: missing {', '.join(missing)}")
    return values


def minor(version: str) -> str:
    """3.15.2 -> 3.15"""
    return ".".join(version.split(".")[:2])


def build_args(values: dict) -> dict:
    """The names the Dockerfiles and the workflows use."""
    args = {REQUIRED[key]: values[key] for key in REQUIRED}
    args["PYTHON_MINOR"] = minor(values["python"])
    args["NODE_MAJOR"] = values["node"].split(".")[0]
    args["GO_MINOR"] = minor(values["go"])
    return args


def main(argv: list) -> int:
    try:
        values = load()
    except (ValueError, OSError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    if len(argv) == 3 and argv[1] == "--get":
        if argv[2] not in values:
            print(f"error: no such key: {argv[2]}", file=sys.stderr)
            return 1
        print(values[argv[2]])
        return 0
    for key, value in build_args(values).items():
        print(f"{key}={value}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
