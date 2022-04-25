terraform {
  required_version = "~> 1.1.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.74.3"
    }
  }

  # backend s3 {
  #   bucket         = "xxx"
  #   key            = "terraform.tfstate"
  #   region         = "ap-northeast-1"
  #   dynamodb_table = "terraform_state_lock"
  # }
}

provider "aws" {
  region              = "ap-northeast-1"

  default_tags {
    tags = {
      Terraform   = true,
    }
  }
}
