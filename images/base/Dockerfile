# lg-static and lg-base: distroless root filesystems built from Debian packages.
#   --target static   CA certificates, tzdata, passwd. No libc: for static binaries (Go with CGO_ENABLED=0, Rust musl).
#   --target base     static + glibc, libstdc++, libgcc, zlib, OpenSSL: for dynamically linked programs
#                     (CPython, Node, C/C++). The runtime images (python, node) start from this one.
# No shell, no package manager: `kubectl debug` with an ephemeral container is how you get in.
ARG DEBIAN_TAG

FROM debian:${DEBIAN_TAG} AS rootfs-static
COPY images/mkrootfs.sh /usr/local/bin/mkrootfs.sh
RUN mkrootfs.sh base-files ca-certificates tzdata netbase

FROM debian:${DEBIAN_TAG} AS rootfs-base
COPY images/mkrootfs.sh /usr/local/bin/mkrootfs.sh
RUN mkrootfs.sh base-files ca-certificates tzdata netbase libc6 libgcc-s1 libstdc++6 zlib1g libssl3t64 libzstd1

FROM scratch AS static
ARG DEBIAN_TAG
LABEL org.opencontainers.image.title="lg-static" \
      org.opencontainers.image.description="Distroless static base: CA certificates, tzdata, nonroot user" \
      org.opencontainers.image.source="https://github.com/lorenzogirardi/ACT-lg-baseimg" \
      org.opencontainers.image.base.name="debian:${DEBIAN_TAG}"
COPY --from=rootfs-static /rootfs/ /
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
USER 65532:65532
WORKDIR /home/nonroot

FROM scratch AS base
ARG DEBIAN_TAG
LABEL org.opencontainers.image.title="lg-base" \
      org.opencontainers.image.description="Distroless glibc base: libc, libstdc++, OpenSSL, CA certificates, tzdata, nonroot user" \
      org.opencontainers.image.source="https://github.com/lorenzogirardi/ACT-lg-baseimg" \
      org.opencontainers.image.base.name="debian:${DEBIAN_TAG}"
COPY --from=rootfs-base /rootfs/ /
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
USER 65532:65532
WORKDIR /home/nonroot
