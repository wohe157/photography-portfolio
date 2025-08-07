variable "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution that will access the S3 bucket"
  type        = string
}

resource "aws_s3_bucket" "media_bucket" {
  bucket        = "wh-photography-portfolio-media"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "media_bucket_website" {
  bucket = aws_s3_bucket.media_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "media_bucket_public_access_block" {
  bucket = aws_s3_bucket.media_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "media_bucket_policy" {
  bucket = aws_s3_bucket.media_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly",
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action = [
          "s3:GetObject"
        ],
        Resource = "${aws_s3_bucket.media_bucket.arn}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = var.cloudfront_distribution_arn
          }
        }
      }
    ]
  })
}

output "bucket_id" {
  value = aws_s3_bucket.media_bucket.id
}

output "bucket_name" {
  value = aws_s3_bucket.media_bucket.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.media_bucket.arn
}

output "bucket_domain_name" {
  value = aws_s3_bucket.media_bucket.bucket_regional_domain_name
}

output "website_domain_name" {
  value = aws_s3_bucket_website_configuration.media_bucket_website.website_endpoint
}
