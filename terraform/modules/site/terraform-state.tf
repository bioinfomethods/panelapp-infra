// S3 buckets and DynamoDB tables for Terraform state and locking

resource "aws_s3_bucket" "terraform" {
  bucket = "${var.stack}-${var.env_name}-${var.account_id}-${var.region}-terraform-state"
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
      days = 14
    }
  }

  tags = "${merge(var.default_tags,
          map("Name", "${var.stack}-${var.env_name}-${var.account_id}-${var.region}-terraform-state"))}"
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
