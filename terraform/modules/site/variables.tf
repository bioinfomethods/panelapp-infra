variable "stack" {}
variable "env_name" {}
variable "account_id" {}
variable "region" {}

variable "create_public_dns_zone" {
  default = true
}

variable "public_dns_zone_name" {}

variable "default_tags" {
  type = "map"
}

variable "enable_datadog" {
  default = false
}

variable "datadog_aws_integration_external_id" {
  default = ""
}


variable "trusted_accounts" {
  type        = "list"
  description = "List accounts allowed to acess RDS KMS key"
}

variable "share_rds_kms_key" {
  default = false
}
