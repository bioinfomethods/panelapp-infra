resource "aws_route53_delegation_set" "shared" {
  reference_name = "${var.stack}-${var.env_name}"
}

resource "aws_route53_zone" "public" {
  count             = var.create_public_dns_zone ? 1 : 0
  name              = var.public_dns_zone_name
  delegation_set_id = aws_route53_delegation_set.shared.id
  tags              = merge(var.default_tags, tomap({"Name": var.public_dns_zone_name }))
}

resource "aws_route53_record" "test" {
  allow_overwrite = true
  name            = "test"
  ttl             = 30
  type            = "NS"
  zone_id         = aws_route53_zone.public[0].zone_id

  records         = var.test_panelapp_ns_records
}

resource "aws_route53_record" "stage" {
  allow_overwrite = true
  name            = "stage"
  ttl             = 30
  type            = "NS"
  zone_id         = aws_route53_zone.public[0].zone_id

  records         = var.stage_panelapp_ns_records
}

resource "aws_route53_record" "prod" {
  allow_overwrite = true
  name            = "prod"
  ttl             = 30
  type            = "NS"
  zone_id         = aws_route53_zone.public[0].zone_id

  records         = var.prod_panelapp_ns_records
}

################
#   Route 53
################


data "aws_route53_zone" "route53_public" {
  zone_id      = var.public_route53_zone_id
}

resource "aws_route53_record" "ns_test" {
  allow_overwrite = true
  name            = "test"
  ttl             = 30
  type            = "NS"
  zone_id         = data.aws_route53_zone.route53_public.zone_id

  records         = var.test_panelapp_ns_records
}

resource "aws_route53_record" "ns_stage" {
  allow_overwrite = true
  name            = "stage"
  ttl             = 30
  type            = "NS"
  zone_id         = data.aws_route53_zone.route53_public.zone_id

  records         = var.stage_panelapp_ns_records
}

resource "aws_route53_record" "ns_prod" {
  allow_overwrite = true
  name            = "prod"
  ttl             = 30
  type            = "NS"
  zone_id         = data.aws_route53_zone.route53_public.zone_id

  records         = var.prod_panelapp_ns_records
}
