resource "docker_network" "consul-net" {
  name = "${var.docker_net_name}"
  check_duplicate = "true"
  driver = "bridge"
}

module "consul_cluster_dc1" {
  source = "./modules/consul-cluster"

  image = var.image
  container_basename = "${var.container_basename}-dc1"
  docker_net_name = "${var.docker_net_name}"
  external_ports_start = 30000

  num_servers = var.num_servers
  num_clients = var.num_clients
  datacenter = "chris1"
  primary_datacenter = "chris1"
}

module "consul_cluster_dc2" {
  source = "./modules/consul-cluster"

  image = var.image
  container_basename = "${var.container_basename}-dc2"
  docker_net_name = "${var.docker_net_name}"
  external_ports_start = 31000

  num_servers = var.num_servers
  num_clients = var.num_clients
  datacenter = "chris2"
  primary_datacenter = "chris1"
  wan_retry_address = module.consul_cluster_dc1.server_addresses[0]
}

module "ingress" {
  source = "./modules/ingress-gateway"

  image = "envoy-consul"
  container_basename = "${var.container_basename}"
  docker_net_name = "${var.docker_net_name}"

  agent_address = module.consul_cluster_dc1.server_addresses[0]
}
