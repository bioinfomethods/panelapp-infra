data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.64.0"


  name = "panelapp-${var.env_name}"
  tags = "${var.default_tags}"

  azs  = "${data.aws_availability_zones.available.names}"
  cidr = "172.20.0.0/21"

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnets     = ["172.20.2.0/24", "172.20.3.0/24"]
  private_subnets    = ["172.20.4.0/24", "172.20.5.0/24"]
  enable_nat_gateway = true
  enable_vpn_gateway = false
  single_nat_gateway = true
}
