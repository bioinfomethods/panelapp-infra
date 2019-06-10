# output "aurora_security_group" {
#   value = "${module.aurora.aurora_security_group}"
# }
output "writer_endpoint" {
  value = "${module.aurora.writer_endpoint}"
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

# output "ses_password" {
#   value = "${aws_iam_access_key.ses.ses_smtp_password}"
# }

# output "ses_id" {
#   value = "${aws_iam_access_key.ses.id}"
# }

output "db_host" {
  value = "${data.aws_ssm_parameter.db_host.value}"
}
