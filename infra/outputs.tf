output "frontend_website_url" {
  value       = module.frontend.website_url
  description = "URL of the frontend site"
}

output "media_bucket_url" {
  value       = module.media.website_url
  description = "URL of the media site"
}

output "backend_api_url" {
  value       = module.backend.api_url
  description = "URL of the deployed backend API"
}

output "random_id" {
  value = random_id.suffix.hex
}
