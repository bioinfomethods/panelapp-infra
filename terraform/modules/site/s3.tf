resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.stack}-${var.env_name}-${var.account_id}-${var.region}-artifacts"

  tags = merge(var.default_tags,
    tomap({ "Name" : "${var.stack}-${var.env_name}-${var.account_id}-${var.region}-artifacts" }))
}

resource "aws_s3_bucket_ownership_controls" "artifacts_ownership_controls" {
  bucket = aws_s3_bucket.artifacts.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "artifacts_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.artifacts_ownership_controls]

  bucket = aws_s3_bucket.artifacts.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "artifacts_versioning" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "artifacts_lifecycle" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    id = "rule-everything"
    filter {
      prefix = "*"
    }
    noncurrent_version_expiration {
      noncurrent_days = 180
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aws_s3_bucket_artifacts_encryption" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.site.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
