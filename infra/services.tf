resource "aws_iam_policy" "list_media_bucket_policy" {
  name        = "wh-photography-media-bucket-list-policy"
  description = "Allows Lambda to list media bucket contents"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:ListBucket"]
        Effect   = "Allow"
        Resource = module.media.bucket_arn
      }
    ]
  })
}

module "list_media_lambda" {
  source = "./lambda_service"

  function_name     = "wh-photography-list-media"
  archive_file_path = "../build/list-media.zip"
  environment_variables = {
    MEDIA_BUCKET = module.media.bucket_name
  }
}

resource "aws_iam_role_policy_attachment" "lambda_s3_attach" {
  role       = module.list_media_lambda.role_name
  policy_arn = aws_iam_policy.list_media_bucket_policy.arn
}
