variable "image" {
  default = "envoy-consul"
}

variable "container_basename" {
  default = "consul"
}

variable "docker_net_name" {
  default = "consul-net"
}

variable "agent_address" {
  default = ""
}
