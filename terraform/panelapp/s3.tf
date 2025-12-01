data "cloudflare_ip_ranges" "cloudflare" {}

resource "aws_s3_bucket" "panelapp_statics" {
  bucket = "${var.stack}-${var.env_name}-${var.account_id}-${var.region}-panelapp-statics"
  tags = merge(
    var.default_tags,
    tomap({ "Name" : "panelapp_static" })
  )
}

resource "aws_s3_bucket_ownership_controls" "panelapp_statics_ownership_controls" {
  bucket = aws_s3_bucket.panelapp_statics.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "panelapp_statics_block_config" {
  bucket = aws_s3_bucket.panelapp_statics.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "panelapp_statics_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.panelapp_statics_ownership_controls,
    aws_s3_bucket_public_access_block.panelapp_statics_block_config
  ]

  bucket = aws_s3_bucket.panelapp_statics.id
  acl    = "public-read"
}

resource "aws_s3_bucket_versioning" "panelapp_statics_versioning" {
  bucket = aws_s3_bucket.panelapp_statics.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "panelapp_statics_cloudfront" {
  count  = var.create_cloudfront ? 1 : 0
  bucket = aws_s3_bucket.panelapp_statics.id
  policy = data.aws_iam_policy_document.s3_static_policy_cloudfront[0].json
}

resource "aws_s3_bucket_policy" "panelapp_statics_cloudflare" {
  count  = !var.create_cloudfront ? 1 : 0
  bucket = aws_s3_bucket.panelapp_statics.id
  policy = data.aws_iam_policy_document.s3_static_policy_cloudflare[0].json
}

data "aws_iam_policy_document" "s3_static_policy_cloudfront" {
  count = var.create_cloudfront ? 1 : 0

  statement {
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.panelapp_statics.arn}/*"]

    principals {
      type = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.panelapp_s3[0].iam_arn]
    }
  }

  statement {
    actions = ["s3:ListBucket"]
    resources = [aws_s3_bucket.panelapp_statics.arn]

    principals {
      type = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.panelapp_s3[0].iam_arn]
    }
  }
}

data "aws_iam_policy_document" "s3_static_policy_cloudflare" {
  count = !var.create_cloudfront ? 1 : 0

  statement {
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.panelapp_statics.arn}/*"]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values = [data.cloudflare_ip_ranges.cloudflare.ipv4_cidr_blocks]
    }

    principals {
      type = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket" "panelapp_media" {
  bucket = "${var.stack}-${var.env_name}-${var.account_id}-${var.region}-panelapp-media"

  tags = merge(
    var.default_tags,
    tomap({ "Name" : "panelapp_media" })
  )
}

resource "aws_s3_bucket_ownership_controls" "panelapp_media_ownership_controls" {
  bucket = aws_s3_bucket.panelapp_media.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "panelapp_media_block_config" {
  bucket = aws_s3_bucket.panelapp_media.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "panelapp_media_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.panelapp_media_ownership_controls,
    aws_s3_bucket_public_access_block.panelapp_media_block_config
  ]

  bucket = aws_s3_bucket.panelapp_media.id
  acl    = "public-read"
}

resource "aws_s3_bucket_versioning" "panelapp_media_versioning" {
  bucket = aws_s3_bucket.panelapp_media.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "panelapp_media_lifecycle" {
  bucket = aws_s3_bucket.panelapp_media.id

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

resource "aws_s3_bucket_policy" "panelapp_media_cloudfront" {
  count  = var.create_cloudfront ? 1 : 0
  bucket = aws_s3_bucket.panelapp_media.id
  policy = data.aws_iam_policy_document.s3_media_policy_cloudfront[0].json
}

resource "aws_s3_bucket_policy" "panelapp_media_cloudflare" {
  count  = !var.create_cloudfront ? 1 : 0
  bucket = aws_s3_bucket.panelapp_media.id
  policy = data.aws_iam_policy_document.s3_media_policy_cloudflare[0].json
}

data "aws_iam_policy_document" "s3_media_policy_cloudfront" {
  count = var.create_cloudfront ? 1 : 0

  statement {
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.panelapp_media.arn}/*"]

    principals {
      type = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.panelapp_s3[0].iam_arn]
    }
  }

  statement {
    actions = ["s3:ListBucket"]
    resources = [aws_s3_bucket.panelapp_media.arn]

    principals {
      type = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.panelapp_s3[0].iam_arn]
    }
  }
}

data "aws_iam_policy_document" "s3_media_policy_cloudflare" {
  count = !var.create_cloudfront ? 1 : 0

  statement {
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.panelapp_media.arn}/*"]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values = [data.cloudflare_ip_ranges.cloudflare.ipv4_cidr_blocks]
    }

    principals {
      type = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket" "panelapp_scripts" {
  bucket = "${var.stack}-${var.env_name}-${var.account_id}-${var.region}-panelap-scripts"

  tags = merge(
    var.default_tags,
    tomap({ "Name" : "panelapp_scripts" })
  )
}

resource "aws_s3_bucket_versioning" "panelapp_scripts_versioning" {
  bucket = aws_s3_bucket.panelapp_scripts.id
  versioning_configuration {
    status = "Enabled"
  }
}

// Reports bucket
resource "aws_s3_bucket" "panelapp_reports" {
  bucket = "${var.stack}-${var.env_name}-${var.account_id}-${var.region}-panelapp-reports"

  tags = merge(
    var.default_tags,
    tomap({ "Name" : "panelapp_reports" })
  )
}

resource "aws_s3_bucket_ownership_controls" "panelapp_reports_ownership_controls" {
  bucket = aws_s3_bucket.panelapp_reports.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "panelapp_reports_block_config" {
  bucket = aws_s3_bucket.panelapp_reports.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "panelapp_reports_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.panelapp_reports_ownership_controls,
    aws_s3_bucket_public_access_block.panelapp_reports_block_config
  ]

  bucket = aws_s3_bucket.panelapp_reports.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "panelapp_reports_versioning" {
  bucket = aws_s3_bucket.panelapp_reports.id
  versioning_configuration {
    status = "Enabled"
  }
}

// IAM Policies for report bucket acces by ECS Task Panelapp
resource "aws_iam_policy" "panelapp_reports_read" {
  name   = "panelapp-reports-read-${var.stack}-${var.env_name}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowGetObject"
        Effect = "Allow"
        Action = ["s3:GetObject"]
        Resource = ["${aws_s3_bucket.panelapp_reports.arn}/*"]
      },
      {
        Sid = "AllowListBucket"
        Effect = "Allow"
        Action = ["s3:ListBucket"]
        Resource = ["${aws_s3_bucket.panelapp_reports.arn}"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "panelapp_reports_read" {
  role       = aws_iam_role.ecs_task_panelapp.name
  policy_arn = aws_iam_policy.panelapp_reports_read.arn
}

resource "aws_iam_user" "panelapp_reports_uploader" {
  name = "panelapp-reports-uploader-${var.stack}-${var.env_name}"
  path = "/service-users/"

  tags = merge(
    var.default_tags,
    tomap({ "Name" = "panelapp_reports_uploader" })
  )
}

// IAM Policies for report user such that we can upload to the bucket
resource "aws_iam_user_policy" "panelapp_reports_uploader_policy" {
  user = aws_iam_user.panelapp_reports_uploader.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowPutObject"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = ["${aws_s3_bucket.panelapp_reports.arn}/*"]
      },
      {
        Sid = "AllowListBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = ["${aws_s3_bucket.panelapp_reports.arn}"]
      },
      {
        Sid = "OptionalMultipartAndDelete"
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:DeleteObject"
        ]
        Resource = ["${aws_s3_bucket.panelapp_reports.arn}/*"]
      }
    ]
  })
}

resource "aws_iam_access_key" "panelapp_reports_uploader_key" {
  user = aws_iam_user.panelapp_reports_uploader.name
}

output "panelapp_reports_uploader_access_key_id" {
  value     = aws_iam_access_key.panelapp_reports_uploader_key.id
  sensitive = true
}

output "panelapp_reports_uploader_secret_access_key" {
  value     = aws_iam_access_key.panelapp_reports_uploader_key.secret
  sensitive = true
}