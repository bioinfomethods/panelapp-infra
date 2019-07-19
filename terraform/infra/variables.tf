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

variable "gitlab_runner_image_tag" {
  description = "Image tag of the gitlab runner image in the ECR"
  default     = "0.11.13"
}

variable "create_runner_terraform" {
  default = false
}

variable "cidr" {
  description = "cidr for VPC"
}

variable "public_subnets" {
  description = "cidr list for public subnets"
  type        = "list"
}

variable "private_subnets" {
  description = "cidr list for private subnets"
  type        = "list"
}

variable "master_account" {
  default = ""
}

variable "enable_datadog" {
  default = false
}

variable "datadog_aws_integration_external_id" {
  default = ""
}
