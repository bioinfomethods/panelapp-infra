resource "aws_kms_key" "shared" {
  description = "${var.stack} shared key in ${var.region}"
  policy      = ""
}

resource "aws_kms_alias" "shared" {
  name          = "alias/${var.stack}-${var.env_name}"
  target_key_id = aws_kms_key.shared.key_id
}
