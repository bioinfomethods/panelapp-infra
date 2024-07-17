output "psql_security_id" {
  value = join("", aws_security_group.postgres_client.*.id)
}

output "user_data" {
  value = aws_launch_configuration.this.user_data
}

output "ssm_role" {
  value = aws_iam_instance_profile.ssm_session_profile.name
}
