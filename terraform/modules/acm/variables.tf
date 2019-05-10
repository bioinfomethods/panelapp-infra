variable "stack" {}
variable "env_name" {}
variable "account_id" {}
variable "region" {}
variable "public_zone_id" {}

variable "default_tags" {
  type = "map"
}

variable "create_global_cert" {
  default = false
}

variable "create_regional_cert" {
  default = false
}
