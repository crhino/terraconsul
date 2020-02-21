output "server_addresses" {
  value = data.template_file.server_names.*.rendered
}
