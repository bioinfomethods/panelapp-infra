resource "aws_acm_certificate" "regional_cert" {
  count             = var.create_regional_cert ? 1 : 0
  domain_name       = "*.${replace(data.aws_route53_zone.acm_domain[0].name, "/[.]$/", "")}"
  subject_alternative_names = [replace(data.aws_route53_zone.acm_domain[0].name, "/[.]$/", "")]
  validation_method = "DNS"

  tags_all = {
    Name : "${var.stack}-${var.env_name}"
  }
}

// KNOWN ISSUE with Certificate Validation
//  When creating multiple certificates for the same domain name but in different Regions, the CNAME record AWS expects
//  for validation is exactly the same, apparently. When creating both Regional and Global certificates this causes an error
//  as Terraform tries to create two different resources that are actually the same DNS record (AWS throws an error on
//  creating the duplicate record).
// WORKAROUND
//  As a workaround, we are not creating the Regional Cert Validation record if we are also generating the Global Cert
//  at the same time. This might cause problems if you generate the two certificates with two different Terraform runs.
//  Also, this way we are not checking whether the Regional Cert Validation has actually passed.

resource "aws_route53_record" "regional_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.regional_cert[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.acm_domain[0].zone_id
}

resource "aws_acm_certificate_validation" "regional_cert" {
  count    = var.create_regional_cert ? 1 : 0

  certificate_arn = aws_acm_certificate.regional_cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.regional_cert_validation : record.fqdn]
}
