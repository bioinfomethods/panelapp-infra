resource "aws_route53_delegation_set" "site" {
  count          = "${var.create_public_dns_zone ? 1 : 0}"
  reference_name = "${var.stack}-${var.env_name}"
}

resource "aws_route53_zone" "public" {
  count             = "${var.create_public_dns_zone ? 1 : 0}"
  name              = "${var.public_dns_zone_name}"
  delegation_set_id = "${aws_route53_delegation_set.site.id}"
  tags              = "${merge(var.default_tags, map("Name", "${var.public_dns_zone_name}"))}"
}
