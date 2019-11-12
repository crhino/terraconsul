provider "docker" {
}

data "template_file" "server_names" {
  count = "${var.num_servers}"
  template = "${var.container_basename}-srv$${srv_num}"
  vars = {
    srv_num = "${count.index}"
  }
}

resource "docker_network" "consul-net" {
  name = "${var.docker_net_name}"
  check_duplicate = "true"
  driver = "bridge"
}

resource "docker_container" "servers" {
  privileged = true
  publish_all_ports = true
  image = "${var.image}"
  name = "${data.template_file.server_names.*.rendered[count.index]}"
  hostname = "${data.template_file.server_names.*.rendered[count.index]}"
  labels = {}
  networks = ["${var.docker_net_name}"]
  network_mode = "${var.docker_net_name}"
  # command = concat(list("agent", "-server", "-client=0.0.0.0", "-bootstrap-expect=${var.num_servers}"),formatlist("--retry-join=%s", concat(slice(data.template_file.server_names.*.rendered, 0, count.index), slice(data.template_file.server_names.*.rendered, count.index + 1, length(data.template_file.server_names.*.rendered)))))
  command = concat(list("agent", "-server", "-client=0.0.0.0", "-ui", "-bootstrap-expect=${var.num_servers}"),formatlist("--retry-join=%s",data.template_file.server_names.*.rendered), list("-hcl=connect { enabled = true }"))
  env=["CONSUL_BIND_INTERFACE=eth0", "CONSUL_ALLOW_PRIVILEGED_PORTS=yes"]
  count = "${var.num_servers}"
}

data "template_file" "client_names" {
  count = "${var.num_clients}"
  template = "${var.container_basename}-client$${client_num}"
  vars = {
    client_num = "${count.index + 1}"
  }
}

resource "docker_container" "clients" {
  privileged = true
  publish_all_ports = true
  image = "${var.image}"
  name = "${data.template_file.client_names.*.rendered[count.index]}"
  hostname = "${data.template_file.client_names.*.rendered[count.index]}"
  labels = {}
  networks = ["${var.docker_net_name}"]
  network_mode = "${var.docker_net_name}"
  command = concat(list("agent", "-client=0.0.0.0"),formatlist("--retry-join=%s",data.template_file.server_names.*.rendered))
  env=["CONSUL_BIND_INTERFACE=eth0", "CONSUL_ALLOW_PRIVILEGED_PORTS=yes"]
  count = "${var.num_clients}"
}
