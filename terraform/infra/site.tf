module "site" {
  source = "../modules/site"

  stack          = "${var.stack}"
  env_name       = "${var.env_name}"
  account_id     = "${var.account_id}"
  region         = "${var.region}"
  default_tags   = "${var.default_tags}"

  create_public_dns_zone = true
  public_dns_zone_name = "${var.public_dns_zone_name}"
}
