terraform {
  required_version = "~> 0.11.13, < 0.12"

  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 2.8"
}

provider "template" {
  version = "~> 2.1"
}

provider "cloudflare" {
  version = "~> 1.16"
}

// State of `infra` component
data "terraform_remote_state" "infra" {
  backend = "s3"

  config {
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "infra/terraform.tfstate"
    region = "eu-west-2"
  }
}

locals {
  vpc_id                 = "${data.terraform_remote_state.infra.vpc_id}"
  db_password_secret_arn = "arn:aws:ssm:${var.region}:${var.account_id}:parameter/${var.stack}/${var.env_name}/database/master_password"
}
