output "server_public_ip" {
  value = var.ip
}

output "ingest_token" {
  value = data.external.populate_data.result["ingest_token"]
}

output "admin_token" {
  value = data.external.populate_data.result["admin_token"]
}
