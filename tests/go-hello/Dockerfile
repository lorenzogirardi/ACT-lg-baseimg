# Built and run by scripts/test-images.sh: lg-go compiles it, lg-static runs it.
ARG GO_IMAGE
ARG STATIC_IMAGE
FROM ${GO_IMAGE} AS build
COPY go.mod main.go ./
RUN go build -o /out/go-hello .

FROM ${STATIC_IMAGE}
COPY --from=build /out/go-hello /go-hello
ENTRYPOINT ["/go-hello"]
