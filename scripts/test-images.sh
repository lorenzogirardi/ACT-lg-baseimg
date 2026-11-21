#!/usr/bin/env bash
# Smoke tests for the images scripts/build.sh made (lg-<name>:local). A distroless image has no shell,
# so each runtime is proven by running the runtime itself. Exits non-zero on the first failure.
set -euo pipefail
cd "$(dirname "$0")/.."
eval "$(scripts/versions.py)"
pass() { echo "ok   $*"; }
fail() { echo "FAIL $*" >&2; exit 1; }

# --- files and users, read from the image filesystem (nothing can be executed in lg-static) ----------------
for name in static base python node; do
  cid=$(docker create "lg-$name:local" /nonexistent)
  listing=$(docker export "$cid" | tar -t); docker rm "$cid" >/dev/null
  for f in etc/ssl/certs/ca-certificates.crt etc/passwd usr/share/zoneinfo/Europe/Rome var/lib/dpkg/status.d/tzdata; do
    grep -qx "$f" <<<"$listing" || fail "lg-$name has no /$f"
  done
  [ "$(docker inspect -f '{{.Config.User}}' "lg-$name:local")" = "65532:65532" ] || fail "lg-$name does not run as 65532"
  for shell in bin/sh bin/bash usr/bin/apt usr/bin/dpkg; do
    ! grep -qx "$shell" <<<"$listing" || fail "lg-$name contains /$shell: it is not distroless"
  done
  pass "lg-$name: CA bundle, tzdata, nonroot user, no shell or package manager"
done
cid=$(docker create lg-static:local /nonexistent); ! docker export "$cid" | tar -t | grep -q 'libc.so.6' \
  || fail "lg-static contains glibc"; docker rm "$cid" >/dev/null; pass "lg-static carries no libc"

# --- Go: lg-go compiles, lg-static runs ----------------------------------------------------------------------
docker build -q -t lg-go-hello:local --build-arg GO_IMAGE=lg-go:local --build-arg STATIC_IMAGE=lg-static:local tests/go-hello >/dev/null
[ "$(docker run --rm lg-go-hello:local)" = "OK go-hello" ] || fail "go-hello on lg-static"
pass "go: built on lg-go, runs on lg-static"
[[ "$(docker run --rm lg-go:local go version)" == *"go${GO_VERSION}"* ]] || fail "lg-go is not go${GO_VERSION}"
pass "lg-go is go${GO_VERSION}"

# --- Python: the pinned interpreter and every extension module linked ------------------------------------------
out=$(docker run --rm lg-python:local -c "import sys; print('.'.join(map(str, sys.version_info[:3])))")
[ "$out" = "$PYTHON_VERSION" ] || fail "lg-python is $out, pinned $PYTHON_VERSION"
docker run --rm lg-python:local -c "
import ssl, sqlite3, ctypes, zlib, bz2, lzma, uuid, decimal, hashlib, json, asyncio, pyexpat, datetime, zoneinfo, socket
ssl.create_default_context().load_default_certs()
zoneinfo.ZoneInfo('Europe/Rome')
print('ok')" | grep -qx ok || fail "lg-python: an extension module or certificate is missing"
pass "lg-python is $PYTHON_VERSION, ssl/sqlite3/ctypes/zlib/bz2/lzma/uuid/zoneinfo import"

# --- Node ----------------------------------------------------------------------------------------------------
out=$(docker run --rm lg-node:local -p process.versions.node)
[ "$out" = "$NODE_VERSION" ] || fail "lg-node is $out, pinned $NODE_VERSION"
docker run --rm lg-node:local -e "require('crypto').randomBytes(8); require('tls'); require('zlib'); console.log('ok')" | grep -qx ok \
  || fail "lg-node: crypto/tls/zlib do not load"
pass "lg-node is $NODE_VERSION, crypto/tls/zlib load"
echo "all image tests passed"
