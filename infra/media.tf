module "media" {
  source = "./s3_cloudfront_bucket"

  bucket_name                 = "wh-photography-portfolio-media"
  cloudfront_distribution_arn = aws_cloudfront_distribution.website.arn
}
