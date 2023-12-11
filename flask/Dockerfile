FROM lgirardi/lg-baseimg:edge

LABEL author="k8s.it <l@k8s.it>"
LABEL layer=flask
LABEL area=platform

RUN apt-get update -y && apt-get install -y python3=3.11.2-1+b1 python3-pip && \
    rm -rf /var/lib/apt/lists/* \
    rm /usr/lib/python3.11/EXTERNALLY-MANAGED



