# ACT-lg-baseimg

Distroless base images for the k8s.it applications. No shell, no package manager, non-root. Rebuilt every
Sunday from the current Debian packages and rebuilt again, in cascade, whenever the base changes; the Python,
Node and Go versions are pinned in one file and move only by a reviewed pull request.

| Image | What it is | Size (arm64) | Use it for |
|---|---|---|---|
| `lgirardi/lg-static` | CA certificates, tzdata, nonroot user. No libc | 1.5 MB | Go (`CGO_ENABLED=0`), Rust musl, any static binary |
| `lgirardi/lg-base` | `lg-static` + glibc, libstdc++, OpenSSL | 17 MB | C/C++, anything dynamically linked; the layer the runtimes sit on |
| `lgirardi/lg-python` | CPython `<pinned>` on `lg-base` | 54 MB | Python services |
| `lgirardi/lg-node` | Node.js `<pinned LTS>` on `lg-base` | 141 MB | Node services |
| `lgirardi/lg-go` | Go `<pinned>` toolchain, **build stage only** | 479 MB | `FROM lg-go AS build`; the runtime is `lg-static` |

Also on `ghcr.io/lorenzogirardi/<name>`. Tags: `edge` (base layers, moves every build), `3.15` / `24` / `1.27`
(minor, moves with patch releases), `3.15.2` (exact), `3.15.2-20261121` (exact + build date, immutable in practice).
**In production pin the dated tag or the digest**, so adopting a new base is your decision and a rollback is a tag change.

## Use

```dockerfile
# Python: dependencies are installed in a build stage of the SAME version, the venv is copied over
FROM python:3.15.2-slim-trixie AS build
RUN python -m venv /venv
COPY requirements.txt .
RUN /venv/bin/pip install --no-cache-dir -r requirements.txt

FROM lgirardi/lg-python:3.15.2
COPY --from=build /venv /venv
COPY --chown=65532:65532 app/ /app/app/
WORKDIR /app
EXPOSE 8000
ENTRYPOINT ["/venv/bin/python", "-m", "uvicorn"]
CMD ["app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

```dockerfile
# Go
FROM lgirardi/lg-go:1.27 AS build
COPY . .
RUN go build -o /out/app ./cmd/app
FROM lgirardi/lg-static:edge
COPY --from=build /out/app /app
ENTRYPOINT ["/app"]
```

## Things a distroless image cannot do

- **No `HEALTHCHECK` with `curl`**: use Kubernetes probes, or a Python/Node one-liner as the check command.
- **No `ping`, `traceroute`, `dig`**: they are binaries, and need capabilities. A service that shells out to them
  (pytbak's network tools do) must implement them in the language, or run on a different image.
- **No shell to exec into**: `kubectl debug -it <pod> --image=busybox --target=<container>`.

## How it stays up to date

Read [docs/pipeline.md](docs/pipeline.md). In short: `versions.yaml` pins every version; Renovate opens a pull request
every Monday for a new patch release; the agent pipeline (the one of `flask-test-api`, from `ci-shared@v3`) reviews it,
`PR Checks` builds all five images and smoke-tests them, and it merges when everything is green; on `main` the
`Images` workflow rebuilds the base and then every runtime on top of it, scanning each one before it is pushed.

## Local

```bash
scripts/build.sh && scripts/test-images.sh    # needs Docker; builds lg-*:local
```
