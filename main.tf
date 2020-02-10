module "consul_cluster_dc1" {
  source = "./modules/consul-cluster"

  num_servers = var.num_servers
  num_clients = var.num_clients
  image = var.image
  container_basename = "${var.container_basename}-dc1"
  docker_net_name = "${var.docker_net_basename}-dc1"
}
