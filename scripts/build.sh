#!/usr/bin/env bash
# Build every image locally, in cascade order, tagged lg-<name>:local. The same order and build args as
# .github/workflows/pipeline.yml: base first, the runtimes on top of it.   Usage: scripts/build.sh [name...]
set -euo pipefail
cd "$(dirname "$0")/.."
eval "$(scripts/versions.py)"
only=" ${*:-static base python node go} "
build() {   # $1 name, $2 Dockerfile, rest: extra docker build args
  local name=$1 file=$2; shift 2
  [[ "$only" == *" $name "* ]] || return 0
  echo "==> lg-$name"
  docker build -f "$file" -t "lg-$name:local" --build-arg "DEBIAN_TAG=$DEBIAN_TAG" "$@" .
}
build static images/base/Dockerfile --target static
build base   images/base/Dockerfile --target base
build python images/python/Dockerfile --build-arg BASE_IMAGE=lg-base:local --build-arg "PYTHON_VERSION=$PYTHON_VERSION"
build node   images/node/Dockerfile   --build-arg BASE_IMAGE=lg-base:local --build-arg "NODE_VERSION=$NODE_VERSION"
build go     images/go/Dockerfile     --build-arg "GO_VERSION=$GO_VERSION"
