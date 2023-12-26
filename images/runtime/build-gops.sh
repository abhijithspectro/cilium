#!/bin/bash

# Copyright Authors of Cilium
# SPDX-License-Identifier: Apache-2.0

set -o xtrace
set -o errexit
set -o pipefail
set -o nounset

gops_version="v0.3.26"

mkdir -p /go/src/github.com/google
cd /go/src/github.com/google

git clone https://github.com/google/gops.git
cd gops

git checkout -b "${gops_version}" "${gops_version}"
git --no-pager remote -v
git --no-pager log -1
export GOEXPERIMENT=boringcrypto
for arch in amd64; do
  mkdir -p "/out/linux/${arch}/bin"
  GOARCH="${arch}" CGO_ENABLED=1 GOEXPERIMENT=boringcrypto go build -ldflags "-linkmode=external -extldflags=-static -s -w" -o "/out/linux/${arch}/bin/gops" github.com/google/gops
done

x86_64-linux-gnu-strip /out/linux/amd64/bin/gops
