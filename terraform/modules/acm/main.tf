data "aws_route53_zone" "acm_domain" {
  count   = "${var.create_regional_cert ? 1 : 0}"
  zone_id = "${var.public_zone_id}"
}
