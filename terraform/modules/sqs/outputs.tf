output "sqs_url" {
  value = "${aws_sqs_queue.sqs.id}"
}
