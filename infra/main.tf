provider "aws" {
  region = "eu-west-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

module "frontend" {
  source = "./frontend"
  suffix = random_id.suffix.hex
}

module "media" {
  source = "./media"
  suffix = random_id.suffix.hex
}

module "backend" {
  source            = "./backend"
  media_bucket_name = module.media.bucket_name
  media_bucket_arn  = module.media.bucket_arn
}
