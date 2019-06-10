resource "aws_route53_record" "panelapp_domain" {
  zone_id = "${data.terraform_remote_state.infra.public_dns_zone}"
  name    = "${var.dns_record}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.panelapp_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.panelapp_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}
