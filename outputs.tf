output "server_public_ip" {
  value = [var.ips]
}

output "ingest_token" {
  value = data.external.populate_data[*].result["token"]
}
