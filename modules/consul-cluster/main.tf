provider "docker" {
}

data "template_file" "server_names" {
  count = "${var.num_servers}"
  template = "${var.container_basename}-srv$${srv_num}"
  vars = {
    srv_num = "${count.index}"
  }
}

resource "docker_container" "servers" {
  count = "${var.num_servers}"
  privileged = true
  image = "${var.image}"
  name = "${data.template_file.server_names.*.rendered[count.index]}"
  hostname = "${data.template_file.server_names.*.rendered[count.index]}"
  labels = {}
  networks_advanced {
    name = "${var.docker_net_name}"
    aliases = ["${data.template_file.server_names[count.index].rendered}"]
  }
  command = concat(list("agent", "-server", "-client=0.0.0.0", "-bootstrap-expect=${var.num_servers}"),formatlist("--retry-join=%s", concat(slice(data.template_file.server_names.*.rendered, 0, count.index), slice(data.template_file.server_names.*.rendered, count.index + 1, length(data.template_file.server_names.*.rendered)))))
  env=["CONSUL_BIND_INTERFACE=eth0", "CONSUL_ALLOW_PRIVILEGED_PORTS=yes"]
  ports {
    internal = 8500
    external = var.external_ports_start + count.index
  }
  upload {
    content = templatefile("${path.module}/consul.d/server.json.tmpl",
      {
        datacenter = var.datacenter,
        primary_datacenter = var.primary_datacenter,
        wan_retry_address = var.wan_retry_address,
        master_token = var.master_token,
      })
    file = "/consul/config/server.json"
  }
}

data "template_file" "client_names" {
  count = "${var.num_clients}"
  template = "${var.container_basename}-client$${client_num}"
  vars = {
    client_num = "${count.index}"
  }
}

resource "docker_container" "clients" {
  count = "${var.num_clients}"
  privileged = true
  image = "${var.image}"
  name = "${data.template_file.client_names.*.rendered[count.index]}"
  hostname = "${data.template_file.client_names.*.rendered[count.index]}"
  labels = {}
  networks_advanced {
    name = "${var.docker_net_name}"
  }
  command = concat(list("agent", "-client=0.0.0.0"),formatlist("--retry-join=%s",data.template_file.server_names.*.rendered))
  env=["CONSUL_BIND_INTERFACE=eth0", "CONSUL_ALLOW_PRIVILEGED_PORTS=yes"]
  ports {
    internal = 8500
    external = var.external_ports_start + 100 + count.index
  }

  # This is for the dashboard service
  ports {
    internal = 9002
  }

  upload {
    content = templatefile("${path.module}/consul.d/counting/counting.json.tmpl", { index = "${count.index}" })
    file = "/consul/counting/counting.json"
  }
  upload {
    content = templatefile("${path.module}/consul.d/dashboard/dashboard.json.tmpl", { index = "${count.index}" })
    file = "/consul/dashboard/dashboard.json"
  }
  upload {
    content = templatefile("${path.module}/consul.d/client.json.tmpl",
      {
        datacenter = var.datacenter,
        primary_datacenter = var.primary_datacenter,
      })
    file = "/consul/config/client.json"
  }
}
