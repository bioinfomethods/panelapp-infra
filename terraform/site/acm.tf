module "acm" {
  source = "../modules/acm"

  create_regional_cert = true
  create_global_cert   = true

  stack          = "${var.stack}"
  env_name       = "${var.env_name}"
  account_id     = "${var.account_id}"
  region         = "${var.region}"
  default_tags   = "${var.default_tags}"
  public_zone_id = "${aws_route53_zone.public.zone_id}"

  local_cert_bucket_id = "${aws_s3_bucket.artifacts.id}"
}
