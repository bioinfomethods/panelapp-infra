// Global certs (in us-east-1) for CloudFront

resource "aws_acm_certificate" "global_cert" {
  provider = "aws.us_east_1"
  count    = "${var.create_global_cert}"

  domain_name       = "*.${replace(data.aws_route53_zone.acm_domain.name, "/[.]$/", "")}"
  validation_method = "DNS"

  tags {
    Name = "${var.stack}-${var.env_name}"
  }
}

resource "aws_route53_record" "global_cert_validation" {
  provider = "aws.us_east_1"
  count    = "${var.create_global_cert}"

  name    = "${aws_acm_certificate.global_cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.global_cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.acm_domain.zone_id}"
  records = ["${aws_acm_certificate.global_cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "global_cert" {
  provider = "aws.us_east_1"
  count    = "${var.create_global_cert}"

  certificate_arn         = "${aws_acm_certificate.global_cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.global_cert_validation.fqdn}"]
}
