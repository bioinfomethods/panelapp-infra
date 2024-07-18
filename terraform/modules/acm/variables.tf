variable "stack" {}
variable "env_name" {}
variable "account_id" {}
variable "region" {}
variable "public_route53_zone" {
  type = string
}
variable "public_dns_zone_name" {
  type = string
}

variable "default_tags" {
  type = map(string)
}

variable "create_global_cert" {
  default = true
}

variable "create_regional_cert" {
  default = true
}
