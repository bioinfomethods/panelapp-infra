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

variable "cluster_size" {
  default = 1
}

variable "sqs_queue_with_kms" {
  description = "Whether to create SQS queue with KMS encryption"
  default     = false
}

variable "create_aurora" {
  default = "true"
}

variable "create_sqs" {
  default = "true"
}

variable "sqs_name" {
  default = ""
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

variable "cdn_alis" {
  description = "CDN alias"
  default     = ""
}

variable "dns_record" {
  default = ""
}

variable "smtp_server" {
  default = "email-smtp.eu-west-1.amazonaws.com"
}

variable "default_email" {
  description = "email used as sender"
}

variable "panelapp_email" {
  description = "contact email"
}

variable "admin_email" {
  description = "email used to creat super user task"
  default     = "test@test.com"
}

variable "image_tag" {
  default = "latest"
}

variable "task_cpu" {
  default = 2048
}

variable "task_memory" {
  default = 4096
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

variable "panelapp_image_repo" {
  description = "location for the panelapp name docker image repo"
  default     = "genomicsengland"
}

variable "create_cloudfront" {}

variable "cloudflare_record" {
  description = "record to be added to the cloudflare"
}

variable "cloudflare_zone" {
  description = "zone on cloudflare"
}

variable "cloudflare_static_files_record" {
  description = "cloudflare record to add page rule for static files, pointing to static s3 bucket"
}

variable "cloudflare_media_files_record" {
  description = "cloudflare record to add page rule for media files, pointing to media s3 bucket"
}

variable "create_panelapp_cluster" {
  description = "To whether create panelapp fargate cluster"
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

variable "application_connection_timeout" {
  default = 300
}
