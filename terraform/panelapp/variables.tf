variable "region" {
  description = "AWS Region"
}

variable "terraform_shared_state_s3_bucket" {}
variable "terraform_infra_state_s3_bucket" {}

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

variable "public_dns_zone" {
  description = "Public DNS Zone ID"
}

variable "public_dns_zone_name" {
  description = "Public DNS Zone name"
}

variable "default_tags" {
  type = map(string)
}

variable "cluster_size" {
  default = 1
}

variable "sqs_queue_with_kms" {
  description = "Whether to create SQS queue with KMS encryption"
  type        = bool
  default     = false
}

variable "create_aurora" {
  default = "true"
}

variable "create_sqs" {
  default = true
  type    = bool
}

variable "sqs_name" {
  type    = string
  default = "pannelapp"
}

# FIXME Qualify all the variables below, making it clear they refer to the SQS queue

variable "visibility_timeout_seconds" {
  description = "The visibility timeout for the queue. An integer from 0 to 43200 (12 hours)"
  default     = 360
}

variable "message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days)"
  default     = 345600
}

variable "max_message_size" {
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it. An integer from 1024 bytes (1 KiB) up to 262144 bytes (256 KiB)"
  default     = 262144
}

variable "delay_seconds" {
  description = "The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes)"
  default     = 0
}

variable "receive_wait_time_seconds" {
  description = "The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning. An integer from 0 to 20 (seconds)"
  default     = 0
}

variable "policy" {
  description = "The JSON policy for the SQS queue"
  default     = ""
}

variable "redrive_policy" {
  description = "The JSON policy to set up the Dead Letter Queue, see AWS docs. Note: when specifying maxReceiveCount, you must specify it as an integer (5), and not a string (\"5\")"
  default     = ""
}

variable "fifo_queue" {
  description = "Boolean designating a FIFO queue"
  default     = false
}

variable "content_based_deduplication" {
  description = "Enables content-based deduplication for FIFO queues"
  default     = false
}

variable "panelapp_replica" {
  default = 2
}

variable "cdn_alias" {
  description = "CDN alias"
  default     = ""
}

variable "dns_record" {
  type    = string
  default = ""
}

variable "smtp_server" {
  type    = string
  default = "email-smtp.eu-west-1.amazonaws.com"
}

variable "default_email" {
  type        = string
  description = "email used as sender"
}

variable "panelapp_email" {
  type        = string
  description = "contact email"
}

variable "admin_email" {
  type        = string
  description = "email used to create super user task"
  default     = "test@test.com"
}

variable "admin_secret" {
  type        = string
  description = "password of Django admin user"
  default     = "secret"
}

variable "image_tag" {}

variable "task_cpu" {
  default = 2048
}

variable "task_memory" {
  default = 4096
}

variable "worker_task_cpu" {
  default = 512
}

variable "worker_task_memory" {
  default = 1024
}

variable "log_retention" {
  default = 14
}

variable "log_level" {
  default = "INFO"
}

variable "db_instance_class" {
  description = "size of the database"
  default     = "db.r5.large"
}

variable "mon_interval" {
  default = 0
  type    = number
}

variable "performance_insights_enabled" {
  default = false
  type    = bool
}

variable "performance_insights_retention_period" {
  default = 7
  type    = number
}

variable "create_cloudfront" {
  type    = bool
  default = true
}

variable "cloudflare_api_key" {
  type    = string
  default = "fffffffffffffffffffffffffffffffffffff"
}

variable "cloudflare_record" {
  type = string
  description = "record to be added to the cloudflare"
  default = null
}

variable "cloudflare_zone" {
  type = string
  description = "zone on cloudflare"
  default = null
}

variable "cloudflare_static_files_record" {
  type = string
  description = "cloudflare record to add page rule for static files, pointing to static s3 bucket"
  default = null
}

variable "cloudflare_media_files_record" {
  type = string
  description = "cloudflare record to add page rule for media files, pointing to media s3 bucket"
  default = null
}

variable "waf_acl_cf_req_header_name" {
  description = "CDN (CloudFront or CloudFlare) to ELB request header name"
  type        = string
}

variable "create_panelapp_cluster" {
  description = "To whether create panelapp fargate cluster"
  default     = true
}

variable "admin_url" {
  description = "admin path"
}

variable "aurora_replica" {
  default = 2
}

variable "gunicorn_workers" {
  default = 8
}

variable "gunicorn_accesslog" {
  description = "The Access log file to write to - means log to stdout"
  default     = "-"
}

variable "application_connection_timeout" {
  default = 300
}

variable "EC2_mgmt_count" {
  default = 0
}

variable "snapshot_identifier" {
  default = ""
}

variable "restore_from_snapshot" {
  default = false
}

variable "rds_backup_retention_period" {
  default = 7
}

variable "create_bastion_host" {
  default = false
  type    = bool
}

variable "bastion_host_key_name" {
  default = "id_ed25519"
  type    = string
}

variable "block_public_access" {
  default = false
}

variable "whitelisted_ips" {
  type = list(string)
  default = ["81.134.251.212", "83.151.220.174"]
}

variable "engine_version" {
  default = "13.12"
}

variable "db_family_parameters" {
  default = "aurora-postgresql13"
}

variable "use_cognito" {
  description = "Use Cognito? (true/false)"
  default     = true
}

variable "cognito_alb_app_login_path" {
  description = "PanelApp login path to be intercepted by ALB Cognito authenticate action"
  default     = "/accounts/login/*"
}

variable "cognito_allow_admin_create_user_only" {
  description = "Only allow administrators to create users in Cognito User Pool"
  default     = true
}

variable "cognito_password_length" {
  description = "Cognito User Pool user password length"
  default     = 10
}

variable "cognito_password_symbols_required" {
  description = "Cognito password special character required"
  default     = false
}

variable "master_account" {
  default = ""
}

variable "cidr" {
  type    = string
  default = "172.16.5.0/26"
}

variable "public_subnets" {
  type = list(string)
  default = ["172.16.5.0/28", "172.16.5.16/28"]
}

variable "private_subnets" {
  type = list(string)
  default = ["172.16.5.32/28", "172.16.5.48/28"]
}

variable "create_runner_terraform" {
  type    = bool
  default = false
}

variable "enable_datadog" {
  type    = bool
  default = false
}

variable "datadog_aws_integration_external_id" {
  type = string
}
