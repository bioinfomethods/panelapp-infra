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


variable "create_public_dns_zone" {
  default = true
}

variable "public_dns_zone_name" {
  description = "Public DNS Zone name"
}


variable "terraform_state_s3_bucket" {
  default = "Terraform state S3 bucket"
}
