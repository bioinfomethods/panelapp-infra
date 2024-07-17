data "aws_iam_policy_document" "rds_kms_policy" {
  count = var.share_rds_kms_key ? 1 : 0

  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }

    resources = ["*"]
    actions   = ["kms:*"]
  }

  statement {
    principals {
      type        = "AWS"
      identifiers = var.share_rds_kms_key ? ["arn:aws:iam::${var.trusted_account}:root"] : []
    }

    resources = ["*"]
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:GenerateDataKey",
      "kms:GetKeyRotationStatus",
      "kms:ListResourceTags",
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
  }
}
