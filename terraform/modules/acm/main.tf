// Lookup current public hosted zone
// Can only provide name or zone_id, not both
// May need to hard code this before terraform apply because for some reason, when variables are used, the lookup fails.
data "aws_route53_zone" "acm_domain" {
  count        = (var.create_regional_cert || var.create_global_cert) ? 1 : 0
#   zone_id      = var.public_route53_zone
  # zone_id      = "set me before terraform apply"
  zone_id      = var.public_dns_zone
}

// Additional provider used for CloudFront SSL certificates (must be in us_east_1 Region)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
