# Copyright Authors of Cilium
# SPDX-License-Identifier: Apache-2.0

ARG BASE_IMAGE=scratch
ARG GOLANG_IMAGE=docker.io/library/golang:1.19.10
ARG ALPINE_IMAGE=docker.io/library/alpine:3.17.3@sha256:124c7d2707904eea7431fffe91522a01e5a861a624ee31d03372cc1d138a3126

# BUILDPLATFORM is an automatic platform ARG enabled by Docker BuildKit.
# Represents the plataform where the build is happening, do not mix with
# TARGETARCH
FROM --platform=${BUILDPLATFORM} ${GOLANG_IMAGE} as builder

# TARGETOS is an automatic platform ARG enabled by Docker BuildKit.
ARG TARGETOS
# TARGETARCH is an automatic platform ARG enabled by Docker BuildKit.
ARG TARGETARCH
ARG NOSTRIP
ARG NOOPT
ARG LOCKDEBUG
ARG RACE

ENV GOEXPERIMENT=boringcrypto
ENV GOARCH=amd64
ENV CGO_ENABLED=1

WORKDIR /go/src/github.com/cilium/cilium/clustermesh-apiserver

RUN --mount=type=bind,readwrite,target=/go/src/github.com/cilium/cilium --mount=target=/root/.cache,type=cache --mount=target=/go/pkg,type=cache \
    mkdir -p /out/${TARGETOS}/${TARGETARCH}

COPY etcd-config.yaml /out/${TARGETOS}/${TARGETARCH}/etcd-config.yaml

#ADD Makefile /go/src/github.com/cilium/cilium
#ADD Makefile.* /go/src/github.com/cilium/
#ADD go.mod /go/src/github.com/cilium/cilium/
#ADD go.sum /go/src/github.com/cilium/cilium/
ADD .cache/ /root/.cache/
ADD pkg/ /go/pkg/

ADD . /go/src/github.com/cilium/cilium/

RUN apt-get update && apt-get install -y binutils-aarch64-linux-gnu binutils-x86-64-linux-gnu clang-15 llvm-15 && \
    ln -s /usr/bin/llvm-15 /usr/bin/llvm && ln -s /usr/bin/clang-15 /usr/bin/clang && ln -s /usr/bin/llc-15 /usr/bin/llc

RUN --mount=type=bind,readwrite,target=/go/src/github.com/cilium/cilium --mount=target=/root/.cache,type=cache --mount=target=/go/pkg,type=cache \
    make GOARCH=${TARGETARCH} RACE=${RACE} NOSTRIP=${NOSTRIP} NOOPT=${NOOPT} LOCKDEBUG=${LOCKDEBUG} \
    && mkdir -p /out/${TARGETOS}/${TARGETARCH}/usr/bin && mv clustermesh-apiserver /out/${TARGETOS}/${TARGETARCH}/usr/bin

WORKDIR /go/src/github.com/cilium/cilium

# licenses-all is a "script" that executes "go run" so its ARCH should be set
# to the same ARCH specified in the base image of this Docker stage (BUILDARCH)
RUN --mount=type=bind,readwrite,target=/go/src/github.com/cilium/cilium --mount=target=/root/.cache,type=cache --mount=target=/go/pkg,type=cache \
    make GOARCH=${BUILDARCH} licenses-all && mv LICENSE.all /out/${TARGETOS}/${TARGETARCH}

# BUILDPLATFORM is an automatic platform ARG enabled by Docker BuildKit.
# Represents the plataform where the build is happening, do not mix with
# TARGETARCH
FROM --platform=${BUILDPLATFORM} ${ALPINE_IMAGE} as certs
RUN apk --update add ca-certificates

# BUILDPLATFORM is an automatic platform ARG enabled by Docker BuildKit.
# Represents the plataform where the build is happening, do not mix with
# TARGETARCH
FROM --platform=${BUILDPLATFORM} ${GOLANG_IMAGE} as gops

ENV GOEXPERIMENT=boringcrypto
ENV GOARCH=amd64
ENV CGO_ENABLED=1

# build-gops.sh will build both archs at the same time
WORKDIR /go/src/github.com/cilium/cilium/images/runtime

ADD .cache/ /root/.cache/
ADD pkg/ /go/pkg/

ADD . /go/src/github.com/cilium/cilium/

RUN apt-get update && apt-get install -y binutils-aarch64-linux-gnu binutils-x86-64-linux-gnu clang-15 llvm-15
RUN --mount=type=bind,readwrite,target=/go/src/github.com/cilium/cilium --mount=target=/root/.cache,type=cache --mount=target=/go/pkg,type=cache \
    cd /go/src/github.com/cilium/cilium/images/runtime && ln -s /usr/bin/llvm-15 /usr/bin/llvm && ln -s /usr/bin/clang-15 /usr/bin/clang && ln -s /usr/bin/llc-15 /usr/bin/llc \
     && ./build-gops.sh

FROM ${BASE_IMAGE} as release
# TARGETOS is an automatic platform ARG enabled by Docker BuildKit.
ARG TARGETOS
# TARGETARCH is an automatic platform ARG enabled by Docker BuildKit.
ARG TARGETARCH
LABEL maintainer="maintainer@cilium.io"
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=gops /out/${TARGETOS}/${TARGETARCH}/bin/gops /bin/gops
COPY --from=builder /out/${TARGETOS}/${TARGETARCH}/etcd-config.yaml /var/lib/cilium/etcd-config.yaml
COPY --from=builder /out/${TARGETOS}/${TARGETARCH}/usr/bin/clustermesh-apiserver /usr/bin/clustermesh-apiserver
COPY --from=builder /out/${TARGETOS}/${TARGETARCH}/LICENSE.all /LICENSE.all
WORKDIR /
ENV GOPS_CONFIG_DIR=/
ENTRYPOINT ["/usr/bin/clustermesh-apiserver"]
