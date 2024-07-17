// Global certs (in us-east-1) for CloudFront

resource "aws_acm_certificate" "global_cert" {
  provider = aws.us_east_1
  count    = var.create_global_cert ? 1 : 0

  domain_name       = "*.${replace(data.aws_route53_zone.acm_domain[0].name, "/[.]$/", "")}"
  subject_alternative_names = [replace(data.aws_route53_zone.acm_domain[0].name, "/[.]$/", "")]
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }

  tags_all = {
    Name : "${var.stack}-${var.env_name}"
  }
}

resource "aws_route53_record" "global_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.global_cert[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.acm_domain[0].zone_id
}

# When validating certificate, make sure the domain name NS records match the public hosted zone NS records in Route53.
# Also see https://stackoverflow.com/questions/68177630/aws-acm-certificate-state-is-pending-validation-and-not-changing-to-issues
resource "aws_acm_certificate_validation" "global_cert" {
  provider = aws.us_east_1
  count    = var.create_global_cert ? 1 : 0

  certificate_arn         = aws_acm_certificate.global_cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.global_cert_validation : record.fqdn]
}
