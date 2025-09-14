output "bucket_id" {
  value = aws_s3_bucket.bucket.id
}

output "bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}

output "bucket_domain_name" {
  value = aws_s3_bucket.bucket.bucket_regional_domain_name
}

output "website_domain_name" {
  value = aws_s3_bucket_website_configuration.website_configuration.website_endpoint
}
