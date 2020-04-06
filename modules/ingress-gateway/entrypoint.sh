#!/bin/bash

set -euo pipefail

if [ -z "$1" ]
  then
    echo "No argument supplied, requires agent address"
    exit 1
fi
agent_address=$1
if [ -z "$2" ]
  then
    echo "No second argument supplied, requires ingress service name"
    exit 1
fi
service_name=$2
if [ -z "$3" ]
  then
    echo "No third argument supplied, requires a token"
    exit 1
fi
token=$3

work_dir="/consul/ingress"

export CONSUL_HTTP_ADDR="http://${agent_address}:8500"
export CONSUL_HTTP_TOKEN=$token

apt update -y
apt-get install curl iproute2 dnsutils -y

consul config write ${work_dir}/ingress-gateway.json

consul connect envoy \
  -gateway=ingress \
  -address="$(hostname -i):7777" \
  -service="ingress1" \
  -register \
  -grpc-addr "${agent_address}:8502"
