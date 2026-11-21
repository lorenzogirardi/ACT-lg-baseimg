# lg-python: CPython <PYTHON_VERSION> on lg-base. No shell, no pip, no apt.
# Applications install their dependencies in a build stage (python:<same version>-slim-trixie) into a
# venv and copy the venv here: see README.md. The interpreter is the official CPython build copied
# unchanged, so the version is exactly the pinned one, not whatever Debian ships.
ARG BASE_IMAGE
ARG PYTHON_VERSION
ARG DEBIAN_TAG

FROM python:${PYTHON_VERSION}-slim-trixie AS py
# Strip what a runtime never uses: pip and friends, the test suites, the installers.
RUN rm -rf /usr/local/bin/pip* /usr/local/bin/idle* /usr/local/bin/pydoc* \
           /usr/local/lib/python3*/ensurepip /usr/local/lib/python3*/idlelib \
           /usr/local/lib/python3*/site-packages/pip* /usr/local/lib/python3*/site-packages/setuptools* \
           /usr/local/lib/python3*/site-packages/wheel* /usr/local/lib/python3*/test \
           /usr/local/lib/python3*/*/test /usr/local/lib/python3*/*/tests /usr/local/share/man
COPY images/mkrootfs.sh images/python/deps.sh /usr/local/sbin/
RUN pkgs="$(/usr/local/sbin/deps.sh)" && test -n "$pkgs" && echo "extra libraries: $pkgs" && /usr/local/sbin/mkrootfs.sh $pkgs

FROM ${BASE_IMAGE}
ARG PYTHON_VERSION
LABEL org.opencontainers.image.title="lg-python" \
      org.opencontainers.image.description="CPython ${PYTHON_VERSION} on a distroless glibc base" \
      org.opencontainers.image.source="https://github.com/lorenzogirardi/ACT-lg-baseimg" \
      io.k8s.it.python.version="${PYTHON_VERSION}"
COPY --from=py /rootfs/ /
COPY --from=py /usr/local /usr/local
# No ldconfig cache in an image with no shell: say where libpython lives.
ENV PATH=/usr/local/bin:/venv/bin:$PATH \
    LD_LIBRARY_PATH=/usr/local/lib \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1
ENTRYPOINT ["/usr/local/bin/python3"]
