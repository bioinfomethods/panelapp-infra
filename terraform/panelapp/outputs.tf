output "writer_endpoint" {
  value = "${module.aurora.writer_endpoint}"
}

output "reader_endpoint" {
  value = "${module.aurora.reader_endpoint}"
}

output "sqs_url" {
  value = "${module.sqs.sqs_url}"
}
