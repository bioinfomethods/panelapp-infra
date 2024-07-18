variable "stack" {
  description = "Stack name"
  default     = "panelapp"
}

variable "env_name" {}

variable "account_id" {}
variable "region" {}

variable "create_public_dns_zone" {
  default = false
}

variable "public_route53_zone" {
  type    = string
  default = "setme"
}

variable "public_dns_zone_name" {}

variable "default_tags" {
  type = map(string)
}


variable "test_panelapp_ns_records" {
  type = list(string)
  default = [
    "ns-31.awsdns-03.com",
    "ns-1784.awsdns-31.co.uk",
    "ns-1361.awsdns-42.org",
    "ns-947.awsdns-54.net"
  ]
}

variable "prod_panelapp_ns_records" {
  type = list(string)
  default = [
    "ns-1025.awsdns-00.org",
    "ns-1633.awsdns-12.co.uk",
    "ns-506.awsdns-63.com",
    "ns-657.awsdns-18.net"
  ]
}

variable "stage_panelapp_ns_records" {
  type = list(string)
  default = [
    "ns-1214.awsdns-23.org",
    "ns-1828.awsdns-36.co.uk",
    "ns-427.awsdns-53.com",
    "ns-740.awsdns-28.net"
  ]
}

variable "terraform_state_s3_bucket" {}

variable "master_account" {}
