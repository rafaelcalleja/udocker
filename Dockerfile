ARG RELEASE_PAGE=https://github.com/indigo-dc/udocker/releases/download
ARG BUILD_VERSION=1.3.12
ARG BASE_IMAGE=ubuntu:22.04
FROM $BASE_IMAGE as builder

ARG RELEASE_PAGE=https://github.com/indigo-dc/udocker/releases/download
ARG BUILD_VERSION=1.3.12
ARG BASE_IMAGE=ubuntu:22.04

WORKDIR /builder

RUN apt update && \
    apt install -y --no-install-recommends \
    ca-certificates curl unzip wget jq python3-dev python3-pip \
    git g++ make pkg-config libtool libssl-dev && \
    rm -rf /var/lib/apt/lists/*

RUN wget ${RELEASE_PAGE}/${BUILD_VERSION}/udocker-${BUILD_VERSION}.tar.gz -O udocker.tar.gz && tar zxvf udocker.tar.gz && \
    python3 /builder/udocker-${BUILD_VERSION}/udocker/udocker --allow-root install


FROM $BASE_IMAGE
ARG BUILD_VERSION=1.3.12

RUN apt update -y && \
    apt install -y --no-install-recommends python3-dev python3-pip python-is-python3 curl wget jq tar && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 udocker

WORKDIR /home/udocker

COPY --from=builder --chown=udocker /root/.udocker /home/udocker/.udocker
COPY --from=builder --chown=udocker /builder/udocker-${BUILD_VERSION} /home/udocker/udocker

USER udocker

ENV PATH "/home/udocker/udocker/udocker:$PATH"
ENV HOME "/home/udocker"
ENV USER "udocker"
