module "acm" {
  source = "../modules/acm"

  create_regional_cert = false
  create_global_cert   = var.generate_ssl_certs

  stack                = var.stack
  env_name             = var.env_name
  account_id           = var.account_id
  region               = var.region
  default_tags         = var.default_tags
  public_route53_zone  = module.site.public_dns_zone
  public_dns_zone_name = module.site.public_dns_zone_name
}
