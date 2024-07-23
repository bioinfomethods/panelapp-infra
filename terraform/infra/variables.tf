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

variable "create_public_dns_zone" {
  default = false
  type    = bool
}

variable "public_route53_zone" {
  type = string
}

variable "public_dns_zone_name" {
  description = "Public DNS Zone name"
}

variable "generate_ssl_certs" {
  description = "Enable generation of SSL Certs"
  default     = true
}

variable "default_tags" {
  type = map(string)
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
  type = list(string)
}

variable "private_subnets" {
  description = "cidr list for private subnets"
  type = list(string)
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

variable "trusted_account" {
  description = "Account allowed to access RDS KMS key"
  type        = string
}

variable "share_rds_kms_key" {
  default = false
}

################################
# Set in terraform.tfvars      #
################################
# Note: Some of these are used in "infra" component and some are used in "panelapp" component
# since terraform/terraform-example.tfvars is shared across both
variable "terraform_state_s3_bucket" {}
variable "sqs_name" {}
variable "dns_record" {}
variable "create_cloudfront" {}
variable "cdn_alias" {}
variable "cloudflare_record" {}
variable "cloudflare_zone" {}
variable "cloudflare_static_files_record" {}
variable "cloudflare_media_files_record" {}
variable "waf_acl_cf_req_header_name" {}
variable "panelapp_replica" {}
variable "task_cpu" {}
variable "task_memory" {}
variable "worker_task_cpu" {}
variable "worker_task_memory" {}
variable "log_retention" {}
variable "gunicorn_workers" {}
variable "application_connection_timeout" {}
variable "admin_url" {}
variable "admin_email" {}
variable "admin_secret" {}
variable "default_email" {}
variable "panelapp_email" {}
variable "aurora_replica" {}
variable "db_instance_class" {}
variable "mon_interval" {}
variable "performance_insights_enabled" {}
variable "performance_insights_retention_period" {}
variable "create_bastion_host" {}
variable "bastion_host_key_name" {}
variable "EC2_mgmt_count" {}
