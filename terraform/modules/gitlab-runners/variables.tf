variable "region" {
  default = "eu-west-2"
}

variable "stack" {}
variable "vpc_id" {}

variable "ecs_subnets" {
  type = "list"
}

variable "default_tags" {
  type = "map"
}

variable "create_gitlab_runners" {
  default = true
}

variable "create_runner_terraform" {
  default = false
}

variable "app_image" {}

variable "app_count" {
  default = 1
}

variable "app_cpu" {
  default = "256"
}

variable "app_memory" {
  default = "512"
}

variable "site_kms_key" {
  default = ""
}

variable "master_account" {
  default = "784145085393"
}

variable "token_from" {
  description = "arn for the tocken in parameter store"
  default = ""
}
