resource "aws_secretsmanager_secret" "rds_master_password" {
  count = var.create_aurora ? 1 : 0
  name  = "/${var.stack}/${var.env_name}/database/master_password"
  kms_key_id = var.rds_db_kms_key
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "rds_master_password_ver" {
  secret_id     = aws_secretsmanager_secret.rds_master_password[0].arn
  secret_string = data.aws_ssm_parameter.root_password[0].value
}
