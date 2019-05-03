variable "region" {
  description = "AWS Region"
}

variable "stack" {
  description = "Stack name"
  default     = "panelapp"
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

variable "generate_ssl_certs" {
  description = "Enable generation of SSL Certs"
  default     = true
}

variable "default_tags" {
  type = "map"
}
