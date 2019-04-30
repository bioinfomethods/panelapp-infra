terraform {
  required_version = "~> 0.11.13"
  backend "s3" {}
}

provider "aws" {
  region = "${var.region}"
  version = "~> 2.8"
}

// State of `site` component
data "terraform_remote_state" "site" {
  backend = "s3"

  config {
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "site/terraform.tfstate"
    region = "eu-west-2"
  }
}

locals {
  vpc_id = "${data.terraform_remote_state.site.vpc_id}"

}

