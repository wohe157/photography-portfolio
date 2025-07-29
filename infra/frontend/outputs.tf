output "website_url" {
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
  description = "URL of the S3 static website"
}
