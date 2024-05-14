# File auto-generated from ./bin/outputs

output "private_key_pem" {
  description = "TLS Private keys for flux git repository."
  value       = module.flux.private_key_pem
  sensitive   = True
}
