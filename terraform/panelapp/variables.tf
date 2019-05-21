variable "region" {
  description = "AWS Region"
}

variable "terraform_state_s3_bucket" {}

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

variable "default_tags" {
  type = "map"
}

variable "create_aurora" {
  default = "true"
}

variable "cluster_size" {
  default = 1
}
