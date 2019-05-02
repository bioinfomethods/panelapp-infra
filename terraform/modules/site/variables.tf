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
