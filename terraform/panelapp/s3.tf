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
