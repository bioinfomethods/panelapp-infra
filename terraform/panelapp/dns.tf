resource "aws_route53_record" "panelapp_domain_cloudfront" {
  count = var.create_cloudfront ? 1 : 0
  #   zone_id = data.terraform_remote_state.infra.outputs.public_dns_zone
  zone_id = var.public_dns_zone
  name    = var.dns_record
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.panelapp_distribution[0].domain_name
    zone_id                = aws_cloudfront_distribution.panelapp_distribution[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "panelapp_domain_cloudflare" {
  count   = !var.create_cloudfront ? 1 : 0
  zone_id = data.terraform_remote_state.infra.outputs.public_dns_zone
  name    = var.dns_record
  type    = "A"

  alias {
    name                   = aws_lb.panelapp.dns_name
    zone_id                = aws_lb.panelapp.zone_id
    evaluate_target_health = false
  }
}
