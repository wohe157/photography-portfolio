module "frontend" {
  source = "./s3_cloudfront_bucket"

  bucket_name                 = "wh-photography-portfolio-frontend"
  cloudfront_distribution_arn = aws_cloudfront_distribution.website.arn
}
