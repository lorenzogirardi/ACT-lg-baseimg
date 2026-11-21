#!/usr/bin/env bash
# The fast check the agents run on every change (verify_command in the agent workflows): versions.yaml and the
# scripts. The slow one, building and testing every image, is `scripts/build.sh && scripts/test-images.sh`
# and runs in PR Checks.
set -euo pipefail
cd "$(dirname "$0")/.."
python -I scripts/versions.py >/dev/null
pytest tests -q
