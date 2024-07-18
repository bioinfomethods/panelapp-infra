resource "aws_kms_key" "site" {
  description = "${var.stack} site key in ${var.region}"
  policy      = ""
}

resource "aws_kms_alias" "site" {
  name          = "alias/${var.stack}-${var.env_name}-site"
  target_key_id = aws_kms_key.site.key_id
}

resource "aws_kms_key" "rds_shared" {
  count       = var.share_rds_kms_key ? 1 : 0
  description = "${var.stack} RDS site key in ${var.region}"
  policy      = data.aws_iam_policy_document.rds_kms_policy[0].json
}

resource "aws_kms_alias" "prod_rds_shared" {
  count         = var.share_rds_kms_key ? 1 : 0
  name          = "alias/${var.stack}-${var.env_name}-rds-site"
  target_key_id = aws_kms_key.rds_shared[0].key_id
}
