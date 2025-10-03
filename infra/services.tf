resource "aws_iam_policy" "media_bucket_list_policy" {
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

resource "aws_iam_policy" "media_bucket_read_write_policy" {
  name        = "wh-photography-media-bucket-read-write-policy"
  description = "Allows Lambda to read and write media bucket contents"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Effect   = "Allow"
        Resource = "${module.media.bucket_arn}/*"
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

resource "aws_iam_role_policy_attachment" "list_media_lambda_list_media_policy_attachment" {
  role       = module.list_media_lambda.role_name
  policy_arn = aws_iam_policy.media_bucket_list_policy.arn
}

module "create_thumbnail" {
  source = "./lambda_service"

  function_name     = "wh-photography-create-thumbnail"
  archive_file_path = "../build/create-thumbnail.zip"
  environment_variables = {
    MEDIA_BUCKET = module.media.bucket_name
  }
}

resource "aws_iam_role_policy_attachment" "create_thumbnail_lambda_list_media_policy_attachment" {
  role       = module.create_thumbnail.role_name
  policy_arn = aws_iam_policy.media_bucket_list_policy.arn
}

resource "aws_iam_role_policy_attachment" "create_thumbnail_lambda_read_write_policy_attachment" {
  role       = module.create_thumbnail.role_name
  policy_arn = aws_iam_policy.media_bucket_read_write_policy.arn
}

resource "aws_lambda_permission" "allow_s3_invoke_create_thumbnail" {
  statement_id  = "AllowS3InvokeCreateThumbnail"
  action        = "lambda:InvokeFunction"
  function_name = module.create_thumbnail.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = module.media.bucket_arn
}

resource "aws_s3_bucket_notification" "create_thumbnail_trigger_on_media_bucket_upload" {
  bucket = module.media.bucket_id

  lambda_function {
    lambda_function_arn = module.create_thumbnail.function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "media/original/"
    filter_suffix       = ".jpg"
  }

  depends_on = [
    aws_lambda_permission.allow_s3_invoke_create_thumbnail,
  ]
}
