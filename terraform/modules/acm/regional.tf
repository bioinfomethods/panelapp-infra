resource "aws_acm_certificate" "regional_cert" {
  count             = "${var.create_regional_cert ? 1 : 0}"
  domain_name       = "*.${replace(data.aws_route53_zone.acm_domain.name, "/[.]$/", "")}"
  validation_method = "DNS"

  tags {
    Name = "${var.stack}-${var.env_name}"
  }
}

resource "aws_route53_record" "cert_validation" {
  count   = "${var.create_regional_cert ? 1 : 0}"
  name    = "${aws_acm_certificate.regional_cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.regional_cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.acm_domain.zone_id}"
  records = ["${aws_acm_certificate.regional_cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "regional_cert" {
  count                   = "${var.create_regional_cert ? 1 : 0}"
  certificate_arn         = "${aws_acm_certificate.regional_cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}