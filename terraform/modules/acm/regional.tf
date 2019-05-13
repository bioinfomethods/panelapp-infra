resource "aws_acm_certificate" "regional_cert" {
  count             = "${var.create_regional_cert ? 1 : 0}"
  domain_name       = "*.${replace(data.aws_route53_zone.acm_domain.name, "/[.]$/", "")}"
  validation_method = "DNS"

  tags {
    Name = "${var.stack}-${var.env_name}"
  }
}

// KNOWN ISSUE with Cerfificate Validation
//  When creating multiple cerificates for the same domain name but in different Regions, the CNAME record AWS expects
//  for validation is exactly the same, apparently. When creating both Regional and Global cerficates this causes an error
//  as Terraform tries to create two different recources that are actually the same DNS record (AWS throws an error on
//  creating the duplicate record).
// WORKAROUND
//  As a workaround, we are not creating the Regional Cert Validation record if we are also generating the Global Cert
//  at the same time. This might cause problems if you generate the two certificats with two different Terraform runs.
//  Also, this way we are not checking whether the Regional Cert Validation has actually passed.

resource "aws_route53_record" "cert_validation" {
  count   = "${var.create_regional_cert && !var.create_global_cert ? 1 : 0}"

  name    = "${aws_acm_certificate.regional_cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.regional_cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.acm_domain.zone_id}"
  records = ["${aws_acm_certificate.regional_cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "regional_cert" {
  count                   = "${var.create_regional_cert && !var.create_global_cert ? 1 : 0}"
  certificate_arn         = "${aws_acm_certificate.regional_cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}
