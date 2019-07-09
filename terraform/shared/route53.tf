resource "aws_route53_delegation_set" "shared" {
  reference_name = "${var.stack}-${var.env_name}"
}

resource "aws_route53_zone" "public" {
  count             = "${var.create_public_dns_zone ? 1 : 0}"
  name              = "${var.public_dns_zone_name}"
  delegation_set_id = "${aws_route53_delegation_set.shared.id}"
  tags              = "${merge(var.default_tags, map("Name", "${var.public_dns_zone_name}"))}"
}

resource "aws_route53_record" "test" {
  allow_overwrite = true
  name            = "test"
  ttl             = 30
  type            = "NS"
  zone_id         = "${aws_route53_zone.public.zone_id}"

  records = [
    "ns-1435.awsdns-51.org",
    "ns-157.awsdns-19.com",
    "ns-1836.awsdns-37.co.uk",
    "ns-797.awsdns-35.net",
  ]
}
