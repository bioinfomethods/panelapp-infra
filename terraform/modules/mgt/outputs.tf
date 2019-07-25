output "psql_security_id" {
  value = "${join("", aws_security_group.postgres_client.*.id)}"
}

output "user_data" {
  value = "${data.template_file.user_data.rendered}"
}

output "ssm_role" {
  value = "${aws_iam_instance_profile.ssm_session_profile.name}"
}
