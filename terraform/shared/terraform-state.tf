// S3 buckets and DynamoDB tables for Terraform state and locking

resource "aws_s3_bucket" "terraform" {
  bucket = "${var.stack}-${var.env_name}-${var.account_id}-${var.region}-terraform-state"
#   acl    = "private"
#
#   versioning {
#     enabled = true
#   }
#
#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         kms_master_key_id = "${aws_kms_key.shared.arn}"
#         sse_algorithm     = "aws:kms"
#       }
#     }
#   }
#
#   lifecycle_rule {
#     prefix  = "*"
#     enabled = true
#
#     noncurrent_version_expiration {
#       days = 14
#     }
#   }

  tags = "${merge(var.default_tags,
          tomap({"Name": "${var.stack}-${var.env_name}-${var.account_id}-${var.region}-terraform-state"}))}"
}

resource "aws_s3_bucket_ownership_controls" "terraform_ownership_controls" {
  bucket = aws_s3_bucket.terraform.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "terraform_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.terraform_ownership_controls]

  bucket = aws_s3_bucket.terraform.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "terraform_versioning" {
  bucket = aws_s3_bucket.terraform.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_lifecycle" {
  bucket = aws_s3_bucket.terraform.id

  rule {
    id = "rule-everything"
    filter {
      prefix = "*"
    }
    noncurrent_version_expiration {
      noncurrent_days = 14
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aws_s3_bucket_encryption" {
  bucket = aws_s3_bucket.terraform.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = "${aws_kms_key.shared.arn}"
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "${var.stack}-${var.env_name}-terraform-lock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = "${merge(var.default_tags)}"
}
