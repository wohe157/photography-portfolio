terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
  }

  backend "s3" {
    bucket       = "wh-photography-portfolio-terraform-state"
    key          = "terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "backend" {
  source = "./backend"

  media_bucket_id   = module.media.bucket_id
  media_bucket_name = module.media.bucket_name
  media_bucket_arn  = module.media.bucket_arn
}
