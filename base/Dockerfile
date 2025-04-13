FROM debian:stable-slim

LABEL author="k8s.it <l@k8s.it>"
LABEL layer=base
LABEL area=platform

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -f -y --no-install-recommends && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates lsof procps net-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    update-ca-certificates
