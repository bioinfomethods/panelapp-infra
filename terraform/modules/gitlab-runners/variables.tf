variable "region" {
  default = "eu-west-2"
}

variable "stack" {}
variable "vpc_id" {}

variable "ecs_subnets" {
  type = list(string)
}

variable "default_tags" {
  type = map(string)
}

variable "create_gitlab_runners" {
  default = false
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
  default = ""
}

variable "gitlab_runner_token" {
  description = "arn for the tocken in parameter store"
  default = ""
}

variable "cloudflare_token" {
  description = "cloudflare API tocken"
}

variable "cloudflare_email" {
  description = "cloudflare API e-mail"
}

variable "app_region" {}

variable "additional_runner_tag" {}
