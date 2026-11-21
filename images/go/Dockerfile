# lg-go: the Go toolchain, pinned, for BUILD stages (no gcc: CGO is off; add it in your own stage if needed). There is no Go runtime image: a Go program built
# with CGO_ENABLED=0 runs on lg-static (and one that needs cgo on lg-base).
#
#   FROM lgirardi/lg-go:1.27 AS build
#   RUN go build -o /out/app ./cmd/app
#   FROM lgirardi/lg-static:edge
#   COPY --from=build /out/app /app
ARG DEBIAN_TAG
ARG GO_VERSION

FROM golang:${GO_VERSION}-trixie AS go

FROM debian:${DEBIAN_TAG}
ARG GO_VERSION
LABEL org.opencontainers.image.title="lg-go" \
      org.opencontainers.image.description="Go ${GO_VERSION} toolchain for build stages" \
      org.opencontainers.image.source="https://github.com/lorenzogirardi/ACT-lg-baseimg" \
      io.k8s.it.go.version="${GO_VERSION}"
RUN apt-get update -qq && apt-get -y -qq upgrade \
 && apt-get -y -qq install --no-install-recommends ca-certificates git \
 && rm -rf /var/lib/apt/lists/*
COPY --from=go /usr/local/go /usr/local/go
ENV PATH=/usr/local/go/bin:/go/bin:$PATH \
    GOPATH=/go \
    CGO_ENABLED=0 \
    GOFLAGS=-trimpath
WORKDIR /src
