# lg-node: Node.js <NODE_VERSION> (official binary, unchanged) on lg-base. No shell, no npm, no yarn.
# Applications run `npm ci` in a build stage (node:<same version>-trixie-slim) and copy node_modules here.
ARG BASE_IMAGE
ARG NODE_VERSION

FROM node:${NODE_VERSION}-trixie-slim AS node

FROM ${BASE_IMAGE}
ARG NODE_VERSION
LABEL org.opencontainers.image.title="lg-node" \
      org.opencontainers.image.description="Node.js ${NODE_VERSION} on a distroless glibc base" \
      org.opencontainers.image.source="https://github.com/lorenzogirardi/ACT-lg-baseimg" \
      io.k8s.it.node.version="${NODE_VERSION}"
COPY --from=node /usr/local/bin/node /usr/local/bin/node
ENV NODE_ENV=production
ENTRYPOINT ["/usr/local/bin/node"]
