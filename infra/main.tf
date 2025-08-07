terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "frontend" {
  source = "./frontend"

  cloudfront_distribution_arn = module.cdn.cloudfront_distribution_arn
}

module "media" {
  source = "./media"

  cloudfront_distribution_arn = module.cdn.cloudfront_distribution_arn
}

module "backend" {
  source = "./backend"

  media_bucket_id   = module.media.bucket_id
  media_bucket_name = module.media.bucket_name
  media_bucket_arn  = module.media.bucket_arn
}

module "cdn" {
  source = "./cdn"

  frontend_bucket_domain_name = module.frontend.bucket_domain_name
  media_bucket_domain_name    = module.media.bucket_domain_name
  api_gateway_domain_name     = module.backend.api_gateway_domain_name
  acm_certificate_arn         = "arn:aws:acm:us-east-1:771484536332:certificate/5f5d5bf1-b5db-4420-a5d2-81e5417d9332"
}

output "frontend_bucket_domain_name" {
  value = module.frontend.website_domain_name
}

output "media_bucket_domain_name" {
  value = module.media.website_domain_name
}

output "backend_api_url" {
  value = module.backend.api_gateway_domain_name
}
