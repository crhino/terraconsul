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

variable "docker_net_name" {
  default = "consul-net"
}

variable "external_ports_start" {
  default = 30000
}

variable "datacenter" {
  default = "chris1"
}

variable "primary_datacenter" {
  default = "chris1"
}

variable "wan_retry_address" {
  default = ""
}

variable "master_token" {
  default = "mastertoken"
}

variable "jwt_validation_pub_key" {
  default = ""
}

variable "intro_token" {
  default = ""
}
