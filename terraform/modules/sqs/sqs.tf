resource "aws_sqs_queue" "sqs" {
  count = "${var.create && var.sqs_queue_with_kms == 0 ? 1 : 0}"

  name = "${var.sqs_name}"

  visibility_timeout_seconds  = "${var.visibility_timeout_seconds}"
  message_retention_seconds   = "${var.message_retention_seconds}"
  max_message_size            = "${var.max_message_size}"
  delay_seconds               = "${var.delay_seconds}"
  receive_wait_time_seconds   = "${var.receive_wait_time_seconds}"
  policy                      = "${var.policy}"
  redrive_policy              = "${var.redrive_policy}"
  fifo_queue                  = "${var.fifo_queue}"
  content_based_deduplication = "${var.content_based_deduplication}"

  tags = "${merge(
    var.default_tags,
    map("Name", "${var.sqs_name}")
  )}"
}