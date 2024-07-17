variable "stack" {
  description = "Stack name"
  default     = "panelapp"
}

variable "env_name" {}

variable "account_id" {}
variable "region" {}

variable "create_public_dns_zone" {
  default = true
}

variable "public_dns_zone_name" {}

variable "default_tags" {
  type = map(string)
}

variable "public_route53_zone_id" {
  default = "Z0119482IVU9UTDYAM6Y"
}

variable "test_panelapp_ns_records" {
  type = list(string)
  default = [
    "ns-1932.awsdns-49.co.uk",
    "ns-1301.awsdns-34.org",
    "ns-563.awsdns-06.net",
    "ns-113.awsdns-14.com"
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
