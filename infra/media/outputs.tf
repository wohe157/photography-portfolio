output "website_url" {
  value       = aws_s3_bucket_website_configuration.media.website_endpoint
  description = "URL of the media bucket website"
}

output "bucket_name" {
  value       = aws_s3_bucket.media.id
  description = "Bucket name"
}

output "bucket_arn" {
  value       = aws_s3_bucket.media.arn
  description = "Bucket ARN"
}
