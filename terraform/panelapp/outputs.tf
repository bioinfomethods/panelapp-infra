# output "aurora_security_group" {
#   value = "${module.aurora.aurora_security_group}"
# }

output "db_host" {
  value = module.aurora.writer_endpoint
}

output "db_port" {
  value = module.aurora.port
}

output "db_user" {
  value = module.aurora.database_user
}

output "db_name" {
  value = module.aurora.database_name
}

output "bastion_host_ip" {
  value = var.create_bastion_host ? aws_instance.bastion[0].public_ip : "not created"
}

# output "reader_endpoint" {
#   value = "${module.aurora.reader_endpoint}"
# }
# output "sqs_url" {
#   value = "${aws_sqs_queue.sqs.id}"
# }
# output "s3_var" {
#   value = "${aws_s3_bucket.panelapp_statics.bucket_regional_domain_name}"
# }
# output "ip_block" {
#   value = "${data.aws_ip_ranges.european_us_cloudfront.cidr_blocks}"
# }

output "ses_password" {
  value = aws_iam_access_key.ses.ses_smtp_password_v4
  sensitive = true
}

output "ses_id" {
  value = aws_iam_access_key.ses.id
}
