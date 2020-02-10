variable "num_servers" {
  default = 3
}

variable "num_clients" {
  default = 2
}

variable "image" {
  default = "consul"
}

variable "container_basename" {
  default = "consul"
}

variable "docker_net_basename" {
  default = "consul-net"
}
