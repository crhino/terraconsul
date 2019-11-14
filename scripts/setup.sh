#!/usr/bin/env bash

set -euo pipefail

function install_from_url {
  curl -sfLo /tmp/${2}.zip "${3}"
  docker cp /tmp/${2}.zip ${1}:/tmp

  docker exec ${1} "sh" -c "cd /tmp && {
    unzip -qq \"${2}.zip\"
    mv \"${2}\" \"/usr/local/bin/${2}\"
    chmod +x \"/usr/local/bin/${2}\"
    rm -rf \"${2}.zip\"
  }"
}

function install_envoy_binary {
  local image="envoyproxy/envoy-alpine:v1.11.2"

  docker pull ${image}
  id=$(docker create ${image})
  docker cp ${id}:/usr/local/bin/envoy /tmp/envoy
  docker rm ${id}

  for consul_container in "$@"; do
    docker cp /tmp/envoy ${consul_container}:/usr/local/bin/envoy
  done
}

function register_service {
  docker exec ${1} consul services register ${2}
}

function run_dashboard {
  # port 5000 is defined in the connect stanza of the dashboard.json
  docker exec -d -e PORT=9002 -e COUNTING_SERVICE_URL="http://localhost:5000" \
    ${1} \
    dashboard-service

  docker exec -d ${1} sh \
    -c \
    "consul connect ${2} -sidecar-for dashboard > /consul/dashboard-proxy.log 2>&1"
}

function run_counting {
  docker exec -d -e PORT=9003 \
    ${1} \
    counting-service

  docker exec -d ${1} sh \
    -c \
    "consul connect ${2} -sidecar-for counting > /consul/counting-proxy.log 2>&1"
}

dashboard_service_url="https://github.com/hashicorp/demo-consul-101/releases/download/0.0.1/dashboard-service_linux_amd64.zip"
counting_service_url="https://github.com/hashicorp/demo-consul-101/releases/download/0.0.1/counting-service_linux_amd64.zip"

connect_cmd="proxy"
image="consul-dev"
if [[ -n ${USE_ENVOY+x} ]]; then
  echo "Using 'envoy' as Connect proxy..."
  connect_cmd="envoy"
  image="glibc-consul"
fi

terraform plan -out cluster.plan -var "image=${image}"
terraform apply cluster.plan

if [[ -n ${USE_ENVOY+x} ]]; then
  install_envoy_binary "consul-client1" "consul-client2"
fi

install_from_url "consul-client1" "dashboard-service" "${dashboard_service_url}"
register_service "consul-client1" "/consul/dashboard/dashboard.json"
run_dashboard "consul-client1" ${connect_cmd}

install_from_url "consul-client2" "dashboard-service" "${dashboard_service_url}"
register_service "consul-client2" "/consul/dashboard/dashboard.json"
run_dashboard "consul-client2" ${connect_cmd}

install_from_url "consul-client1" "counting-service" "${counting_service_url}"
register_service "consul-client1" "/consul/counting/counting.json"
run_counting "consul-client1" ${connect_cmd}

install_from_url "consul-client2" "counting-service" "${counting_service_url}"
register_service "consul-client2" "/consul/counting/counting.json"
run_counting "consul-client2" ${connect_cmd}
