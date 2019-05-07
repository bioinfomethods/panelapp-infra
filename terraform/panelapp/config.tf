// Data sources for paramenters in parameter-store

// Not Secrets

data "aws_ssm_parameter" "db_username" {
  name = "/${var.stack}/${var.env_name}/database/master_username"
}

data "aws_ssm_parameter" "db_name" {
  name = "/${var.stack}/${var.env_name}/database/db_name"
}

data "aws_ssm_parameter" "email_host" {
  name = "/${var.stack}/${var.env_name}/email/host"
}

data "aws_ssm_parameter" "email_port" {
  name = "/${var.stack}/${var.env_name}/email/port"
}

data "aws_ssm_parameter" "email_host_username" {
  name = "/${var.stack}/${var.env_name}/email/host_username"
}

data "aws_ssm_parameter" "email_use_tls" {
  name = "/${var.stack}/${var.env_name}/email/use_tls"
}

data "aws_ssm_parameter" "email_from_address" {
  // DEFAULT_FROM_EMAIL
  name = "/${var.stack}/${var.env_name}/email/from_address"
}

data "aws_ssm_parameter" "email_panelapp_address" {
  // DEFAULT_FROM_EMAIL
  name = "/${var.stack}/${var.env_name}/email/panelapp_address"
}

data "aws_ssm_parameter" "web_loglevel" {
  name = "/${var.stack}/${var.env_name}/web/loglevel"
}

// Secrets

data "aws_ssm_parameter" "db_password" {
  name = "/${var.stack}/${var.env_name}/database/master_password"
}

data "aws_ssm_parameter" "web_secret_key" {
  name = "/${var.stack}/${var.env_name}/web/secret_key"
}

data "aws_ssm_parameter" "web_health_check_token" {
  name = "/${var.stack}/${var.env_name}/web/health_check_token"
}

data "aws_ssm_parameter" "email_host_password" {
  name = "/${var.stack}/${var.env_name}/email/host_password"
}
