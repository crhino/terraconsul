#!/bin/bash

set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
CONSUL_WORK_DIR=${HOME}/workspace/consul
LOCAL_DIR=${DIR}/..

pushd ${CONSUL_WORK_DIR}
  make linux
  cp ./pkg/bin/linux_amd64/consul ${LOCAL_DIR}/docker
  make dev-docker
popd

docker build docker -f docker/Consul-Envoy.dockerfile -t consul-envoy
docker build docker -f docker/Envoy-Consul.dockerfile -t envoy-consul --build-arg="ENVOY_VERSION=1.14.1"
