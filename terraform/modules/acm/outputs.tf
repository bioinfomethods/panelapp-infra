output "regional_cert" {
  value = "${coalesce(join("", aws_acm_certificate.regional_cert.*.id), "not_created")}"
}
