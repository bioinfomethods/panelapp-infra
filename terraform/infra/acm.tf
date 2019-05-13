module "acm" {
  source = "../modules/acm"

  create_regional_cert = "${var.generate_ssl_certs}"
  create_global_cert   = "${var.generate_ssl_certs}"

  stack          = "${var.stack}"
  env_name       = "${var.env_name}"
  account_id     = "${var.account_id}"
  region         = "${var.region}"
  default_tags   = "${var.default_tags}"
  public_zone_id = "${module.site.public_dns_zone}"
}
