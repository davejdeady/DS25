terraform {
  required_version = ">= 1.6"

  backend "s3" {
    bucket         = "terraform-state-digital-summit-demo"
    key            = "U611371/terraform.tfstate" //update this per user U account
    region         = "eu-west-2"
    dynamodb_table = "dynamoDB_to_lock_terraform_state"
    encrypt        = true
  }

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.50.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = local.tags
  }
}
