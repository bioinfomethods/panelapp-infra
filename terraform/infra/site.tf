module "site" {
  source = "../modules/site"

  stack             = var.stack
  env_name          = var.env_name
  account_id        = var.account_id
  region            = var.region
  default_tags      = var.default_tags
  share_rds_kms_key = var.share_rds_kms_key
  trusted_account   = var.trusted_account

  create_public_dns_zone = false
  public_dns_zone_name   = var.public_dns_zone_name

  enable_datadog                      = var.enable_datadog
  datadog_aws_integration_external_id = var.datadog_aws_integration_external_id
}
