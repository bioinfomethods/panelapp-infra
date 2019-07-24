data "template_file" "principal_arns" {
  count    = "${var.share_rds_kms_key ? length(var.trusted_accounts) : 0}"
  template = "arn:aws:iam::${var.trusted_accounts[count.index]}:root"
}


data "aws_iam_policy_document" "rds_kms_policy" {
  count = "${var.share_rds_kms_key ? 1 : 0}"

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
      identifiers = ["${data.template_file.principal_arns.*.rendered}"]
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