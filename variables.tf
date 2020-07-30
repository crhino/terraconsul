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

variable "jwt_validation_pub_key" {
  default = ""
}

variable "intro_token" {
  default = ""
}
