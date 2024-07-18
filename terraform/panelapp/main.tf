terraform {
  required_version = ">= 1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.58.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.37.0"
    }
  }

  #   backend "s3" {}
}

provider "aws" {
  region = var.region
}

provider "cloudflare" {
    email   = var.default_email
    api_key = var.cloudflare_api_key
}

// State of `infra` component
data "terraform_remote_state" "infra" {
  backend = "s3"

  config = {
    bucket = var.terraform_state_s3_bucket
    key    = "infra/terraform.tfstate"
    region = var.region
  }
}

locals {
  vpc_id                 = data.terraform_remote_state.infra.outputs.vpc_id
  db_password_secret_arn = "arn:aws:ssm:${var.region}:${var.account_id}:parameter/${var.stack}/${var.env_name}/database/master_password"
}
