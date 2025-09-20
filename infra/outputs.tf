output "frontend_bucket_domain_name" {
  value = module.frontend.website_domain_name
}

output "media_bucket_domain_name" {
  value = module.media.website_domain_name
}

output "backend_api_url" {
  value = module.backend.api_gateway_domain_name
}
