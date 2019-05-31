output "aurora_security_group" {
  value = "${module.aurora.aurora_security_group}"
}

output "writer_endpoint" {
  value = "${module.aurora.writer_endpoint}"
}

output "reader_endpoint" {
  value = "${module.aurora.reader_endpoint}"
}

output "sqs_url" {
  value = "${aws_sqs_queue.sqs.id}"
}
