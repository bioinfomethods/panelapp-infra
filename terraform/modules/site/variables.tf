variable "stack" {}
variable "env_name" {}
variable "account_id" {}
variable "region" {}

variable "create_public_dns_zone" {
  default = false
}

variable "public_dns_zone_name" {}

variable "default_tags" {
  type = map(string)
}

variable "enable_datadog" {
  default = false
  type    = bool
}

variable "datadog_aws_integration_external_id" {
  default = ""
}

variable "trusted_account" {
  type        = string
  description = "Account allowed to access RDS KMS key"
}

variable "share_rds_kms_key" {
  default = false
}
