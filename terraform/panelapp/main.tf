terraform {
  required_version = ">= 1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.58.0"
    }
  }

#   backend "s3" {}
}

provider "aws" {
  region  = var.region
}

provider "template" {
  version = "~> 2.1"
}

provider "cloudflare" {}

// State of `infra` component
data "terraform_remote_state" "infra" {
  backend = "s3"

  config {
    bucket = var.terraform_state_s3_bucket
    key    = "infra/terraform.tfstate"
    region = "eu-west-2"
  }
}

locals {
  vpc_id                 = data.terraform_remote_state.infra.vpc_id
  db_password_secret_arn = "arn:aws:ssm:${var.region}:${var.account_id}:parameter/${var.stack}/${var.env_name}/database/master_password"
}
