output "regional_cert" {
  description = "Regional Certificate ARN"
  value       = "${coalesce(join("", aws_acm_certificate.regional_cert.*.id), "not_created")}"
}

output "global_cert" {
  description = "Global Certificate ARN"
  value       = "${coalesce(join("", aws_acm_certificate.global_cert.*.id), "not_created")}"
}
