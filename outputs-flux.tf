# File auto-generated from ./bin/outputs

output "private_key_pem" {
  description = "TLS Private keys for flux git repository."
  value       = module.flux.private_key_pem
  sensitive   = true
}

output "flux_overlay" {
  description = "Map of variables to inject into overlay files."
  value       = module.flux.flux_overlay
}
