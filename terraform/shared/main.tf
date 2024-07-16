terraform {
  required_version = "~> 0.11.13, < 0.12"

  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 2.8"
}

// Additional provider used for CloudFront SSL certificates (must be in us_east_1 Region)
provider "aws" {
  version = "~> 2.8"
  alias   = "us_east_1"
  region  = "us-east-1"
}
