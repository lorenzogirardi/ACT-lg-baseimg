#!/bin/sh
# Print the Debian packages whose shared libraries the CPython in /usr/local needs, minus the ones
# lg-base already carries. Found with ldd over every ELF file, so a Python bump that links a new
# library is picked up by itself instead of failing at import time in production.
set -eu
export DEBIAN_FRONTEND=noninteractive
command -v ldd >/dev/null || { apt-get update -qq; apt-get -y -qq install libc-bin >/dev/null; }
SKIP=' libc6 libgcc-s1 libstdc++6 zlib1g libssl3t64 libzstd1 '
find /usr/local -type f \( -name '*.so*' -o -perm -u+x \) 2>/dev/null | while IFS= read -r f; do
  head -c4 "$f" 2>/dev/null | grep -q 'ELF' || continue
  LD_LIBRARY_PATH=/usr/local/lib ldd "$f" 2>/dev/null | awk '/=> \// {print $3}'
done | sort -u | while IFS= read -r lib; do
  dpkg -S "$(readlink -f "$lib")" 2>/dev/null | grep -v "^diversion" | cut -d: -f1 | head -n1
done | sort -u | while IFS= read -r pkg; do
  case "$SKIP" in *" $pkg "*) ;; *) echo "$pkg" ;; esac
done
