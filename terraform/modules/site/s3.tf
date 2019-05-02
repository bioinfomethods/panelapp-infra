resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.stack}-${var.env_name}-${var.account_id}-${var.region}-artifacts"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.site.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  lifecycle_rule {
    prefix  = "*"
    enabled = true

    noncurrent_version_expiration {
      days = 180
    }
  }

  tags = "${merge(var.default_tags,
          map("Name", "${var.stack}-${var.env_name}-${var.account_id}-${var.region}-artifacts"))}"
}
