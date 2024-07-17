output "sqs_url" {
  value = aws_sqs_queue.sqs.id
}

output "sqs_arn" {
  value = aws_sqs_queue.sqs.arn
}
