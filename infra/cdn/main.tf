variable "frontend_bucket_domain_name" {
  description = "The domain name for the frontend bucket"
  type        = string
}

variable "media_bucket_domain_name" {
  description = "The domain name for the media bucket"
  type        = string
}

variable "api_gateway_domain_name" {
  description = "The domain name of the deployed API Gateway"
  type        = string
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate for CloudFront"
  type        = string
}

resource "aws_cloudfront_origin_access_control" "frontend_oac" {
  name = "frontend-bucket-oac"

  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_control" "media_oac" {
  name = "media-bucket-oac"

  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  default_root_object = "index.html"
  aliases             = ["photo.wouterheyvaert.be"]

  origin {
    origin_id                = "frontend-bucket-origin"
    domain_name              = var.frontend_bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend_oac.id
  }

  origin {
    origin_id                = "media-bucket-origin"
    domain_name              = var.media_bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.media_oac.id
  }

  origin {
    origin_id   = "api-gateway-origin"
    domain_name = var.api_gateway_domain_name
    origin_path = "/prod"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  ordered_cache_behavior {
    path_pattern     = "/media/*"
    target_origin_id = "media-bucket-origin"

    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
  }

  ordered_cache_behavior {
    path_pattern     = "/api/*"
    target_origin_id = "api-gateway-origin"

    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled
  }

  default_cache_behavior {
    target_origin_id = "frontend-bucket-origin"

    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  price_class = "PriceClass_100"
}

resource "aws_route53_record" "photo" {
  zone_id = "Z079641423OKOLTF94PZV" # wouterheyvaert.be
  name    = "photo"
  type    = "A"

  alias {
    name    = aws_cloudfront_distribution.website.domain_name
    zone_id = aws_cloudfront_distribution.website.hosted_zone_id

    evaluate_target_health = false
  }
}

output "cloudfront_distribution_arn" {
  value = aws_cloudfront_distribution.website.arn
}
