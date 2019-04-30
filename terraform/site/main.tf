terraform {
  required_version = "~> 0.11.13"
  backend "s3" {}
}

provider "aws" {
  region = "${var.region}"
  version = "~> 2.8"
}

// Additional provider of CloudFront SSL cerfificates (must live in Virginia)
provider "aws" {
  version = "~> 2.8"
  alias   = "us_east_1"
  region  = "us-east-1"
}

// FIXME do we need this?
resource "aws_kms_key" "site" {
  description = "${var.stack} site key in ${var.region}"
  policy      = ""
}

resource "aws_kms_alias" "site" {
  name          = "alias/${var.stack}-${var.env_name}-site"
  target_key_id = "${aws_kms_key.site.key_id}"
}

resource "aws_cloudwatch_log_group" "panelapp" {
  name              = "panelapp"
  retention_in_days = 14
}

// FIXME Add Terraform S3 and DynamoDB table

