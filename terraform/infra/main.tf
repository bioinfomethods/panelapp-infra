terraform {
  required_version = ">= 1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.58.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.region
}

// Additional provider used for CloudFront SSL certificates (must be in us_east_1 Region)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
