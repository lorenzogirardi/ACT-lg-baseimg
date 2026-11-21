# ACT-lg-baseimg - instructions for the agents and for people

Distroless base images for the k8s.it applications, rebuilt and kept up to date by themselves.

## What is here

| Path | What |
|---|---|
| `versions.yaml` | The ONLY place a pinned version is written (Debian snapshot, Python, Node, Go). |
| `images/base/Dockerfile` | `lg-static` (no libc) and `lg-base` (glibc) targets, built from Debian packages onto `scratch`. |
| `images/{python,node,go}/Dockerfile` | `lg-python`, `lg-node` on top of `lg-base`; `lg-go` is a build-stage toolchain (runtime is `lg-static`). |
| `images/mkrootfs.sh` | Builds a root filesystem from Debian packages (copies by `dpkg -L`, writes `status.d` records for scanners). |
| `scripts/versions.py` | Reads `versions.yaml` for the Dockerfiles and the workflows. |
| `scripts/build.sh`, `scripts/test-images.sh` | Build all images locally in cascade order; smoke-test them. Same as CI. |
| `legacy/` | The old `lg-baseimg` / `lg-flaskimg`, still rebuilt weekly until nothing pulls them. |

## Rules

- A version is written in `versions.yaml` and nowhere else. Dockerfiles take it as an `ARG`.
- Versions are exact (`3.15.2`), never ranges, `latest` or a floating tag. They change by pull request only.
- No shell, package manager or `curl` in a runtime image. That is the point. Debugging is `kubectl debug` or a variant, not a shell in the image.
- Images run as uid 65532 (`nonroot`).
- No agent edits a file under `.github/workflows/`; a change to the pipeline is written by a person.
- Never commit secrets. Registry credentials are repository secrets (`DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`).
- Tests are the specification: a failing test is fixed in the code, unless the pull request says the behaviour changes on purpose.

## Check a change

```bash
scripts/verify.sh                          # fast: versions.yaml + unit tests (what the agents run)
scripts/build.sh && scripts/test-images.sh # slow: build every image, smoke-test them (PR Checks `build`)
```

Design of the cascade, the update mechanism and the agent pipeline: `docs/pipeline.md`.
