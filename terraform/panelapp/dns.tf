resource "aws_route53_record" "panelapp_domain_cloudfront" {
  count   = "${var.create_cloudfront ? 1 : 0}"
  //zone_id = "${data.terraform_remote_state.infra.public_dns_zone}"
  // could query using data ^^^ but since underlying code coupled tightly to infra state and, plus we created the hosted zone manually at dev.umccr.org to share with other applications
  zone_id = "${var.route53_zone_id}"
  name    = "${var.dns_record}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.panelapp_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.panelapp_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "panelapp_domain_cloudflare" {
  count   = "${!var.create_cloudfront ? 1 : 0}"
  zone_id = "${data.terraform_remote_state.infra.public_dns_zone}"
  name    = "${var.dns_record}"
  type    = "A"

  alias {
    name                   = "${aws_lb.panelapp.dns_name}"
    zone_id                = "${aws_lb.panelapp.zone_id}"
    evaluate_target_health = false
  }
}
