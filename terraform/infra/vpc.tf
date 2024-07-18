data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.9.0"

  name = "panelapp-${var.env_name}"
  tags = var.default_tags

  azs  = data.aws_availability_zones.available.names
  cidr = var.cidr

  enable_dns_hostnames = true
  enable_dns_support   = true
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  enable_nat_gateway   = true
  enable_vpn_gateway   = false
  single_nat_gateway   = true
}
