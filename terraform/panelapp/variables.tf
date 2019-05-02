variable "region" {
  description = "AWS Region"
}

variable "stack" {
  description = "Stack name"
  default = "panelapp"
}

variable "env_name" {
  description = "Environment name"
}

variable "account_id" {
  description = "Account ID"
}

variable "public_dns_zone_name" {
  description = "Public DNS Zone name"
}

variable "default_tags" {
  type = "map"
}
