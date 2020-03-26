resource "docker_container" "ingress" {
  count = 1
  privileged = true
  image = "${var.image}"
  name = "${var.container_basename}-ingress"
  hostname = "${var.container_basename}-ingress"
  labels = {}
  networks_advanced {
    name = "${var.docker_net_name}"
  }
  entrypoint = ["/consul/ingress/entrypoint.sh", "${var.agent_address}", "ingress1", "mastertoken"]

  ports {
    internal = 443
    external = 8443
  }

  upload {
    content = file("${path.module}/service.json")
    file = "/consul/ingress/service.json"
  }
  upload {
    content = file("${path.module}/ingress-gateway.json")
    file = "/consul/ingress/ingress-gateway.json"
  }
  upload {
    content = file("${path.module}/entrypoint.sh")
    file = "/consul/ingress/entrypoint.sh"
    executable = true
  }
}
