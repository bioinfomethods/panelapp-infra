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
    "ns-1932.awsdns-49.co.uk",
    "ns-1301.awsdns-34.org",
    "ns-563.awsdns-06.net",
    "ns-113.awsdns-14.com"
  ]
}

resource "aws_route53_record" "stage" {
  allow_overwrite = true
  name            = "stage"
  ttl             = 30
  type            = "NS"
  zone_id         = "${aws_route53_zone.public.zone_id}"

  records = [
    "ns-1214.awsdns-23.org",
    "ns-1828.awsdns-36.co.uk",
    "ns-427.awsdns-53.com",
    "ns-740.awsdns-28.net"
  ]
}

resource "aws_route53_record" "prod" {
  allow_overwrite = true
  name            = "prod"
  ttl             = 30
  type            = "NS"
  zone_id         = "${aws_route53_zone.public.zone_id}"

  records = [
    "ns-1025.awsdns-00.org",
    "ns-1633.awsdns-12.co.uk",
    "ns-506.awsdns-63.com",
    "ns-657.awsdns-18.net"
  ]
}

################
#   Route 53
################


data "aws_route53_zone" "route53_public" {
  name         = "${var.public_dns_zone_name}"
  zone_id      = "${var.public_route53_zone_id}"
}

resource "aws_route53_record" "test" {
  allow_overwrite = true
  name            = "test"
  ttl             = 30
  type            = "NS"
  zone_id         = "${data.aws_route53_zone.route53_public.zone_id}"

  records = [
    "ns-1932.awsdns-49.co.uk",
    "ns-1301.awsdns-34.org",
    "ns-563.awsdns-06.net",
    "ns-113.awsdns-14.com"
  ]
}

resource "aws_route53_record" "stage" {
  allow_overwrite = true
  name            = "stage"
  ttl             = 30
  type            = "NS"
  zone_id         = "${data.aws_route53_zone.route53_public.zone_id}"

  records = [
    "ns-1214.awsdns-23.org",
    "ns-1828.awsdns-36.co.uk",
    "ns-427.awsdns-53.com",
    "ns-740.awsdns-28.net"
  ]
}

# Will be added as part-2 

//resource "aws_route53_record" "prod" {
//  allow_overwrite = true
//  name            = "prod"
//  ttl             = 30
//  type            = "NS"
//  zone_id         = "${data.aws_route53_zone.route53_public.zone_id}"
//
//  records = [
//    "ns-1025.awsdns-00.org",
//    "ns-1633.awsdns-12.co.uk",
//    "ns-506.awsdns-63.com",
//    "ns-657.awsdns-18.net"
//  ]
//}