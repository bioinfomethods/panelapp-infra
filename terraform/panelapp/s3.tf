data "cloudflare_ip_ranges" "cloudflare" {}

resource "aws_s3_bucket" "panelapp_statics" {
  bucket = "${var.stack}-${var.env_name}-${var.account_id}-${var.region}-panelapp-statics"

  acl = "private"  //FIXME must be fronted by CloudFront instead, we have disabled all public access from our accounts

  versioning {
    enabled = false
  }

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_static")
  )}"
}

resource "aws_s3_bucket_policy" "panelapp_statics_cloudfront" {
  count  = "${var.create_cloudfront ? 1 : 0}"
  bucket = "${aws_s3_bucket.panelapp_statics.id}"
  policy = "${data.aws_iam_policy_document.s3_static_policy_cloudfront.json}"
}

resource "aws_s3_bucket_policy" "panelapp_statics_cloudflare" {
  count  = "${!var.create_cloudfront ? 1 : 0}"
  bucket = "${aws_s3_bucket.panelapp_statics.id}"
  policy = "${data.aws_iam_policy_document.s3_static_policy_cloudflare.json}"
}

data "aws_iam_policy_document" "s3_static_policy_cloudfront" {
  count = "${var.create_cloudfront ? 1 : 0}"

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.panelapp_statics.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.panelapp_s3.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.panelapp_statics.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.panelapp_s3.iam_arn}"]
    }
  }
}

data "aws_iam_policy_document" "s3_static_policy_cloudflare" {
  count = "${!var.create_cloudfront ? 1 : 0}"

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.panelapp_statics.arn}/*"]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = ["${data.cloudflare_ip_ranges.cloudflare.ipv4_cidr_blocks}"]
    }

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket" "panelapp_media" {
  bucket = "${var.stack}-${var.env_name}-${var.account_id}-${var.region}-panelapp-media"

  policy = ""

  acl = "private"  //FIXME must be fronted by CloudFront instead, we have disabled all public access from our accounts

  versioning {
    enabled = true
  }

  lifecycle_rule {
    prefix  = "*"
    enabled = true

    noncurrent_version_expiration {
      days = 180
    }
  }

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_media")
  )}"
}

resource "aws_s3_bucket_policy" "panelapp_media_cloudfront" {
  count  = "${var.create_cloudfront ? 1 : 0}"
  bucket = "${aws_s3_bucket.panelapp_media.id}"
  policy = "${data.aws_iam_policy_document.s3_media_policy_cloudfront.json}"
}

resource "aws_s3_bucket_policy" "panelapp_media_cloudflare" {
  count  = "${!var.create_cloudfront ? 1 : 0}"
  bucket = "${aws_s3_bucket.panelapp_media.id}"
  policy = "${data.aws_iam_policy_document.s3_media_policy_cloudflare.json}"
}

data "aws_iam_policy_document" "s3_media_policy_cloudfront" {
  count = "${var.create_cloudfront ? 1 : 0}"

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.panelapp_media.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.panelapp_s3.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.panelapp_media.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.panelapp_s3.iam_arn}"]
    }
  }
}

data "aws_iam_policy_document" "s3_media_policy_cloudflare" {
  count = "${!var.create_cloudfront ? 1 : 0}"

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.panelapp_media.arn}/*"]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = ["${data.cloudflare_ip_ranges.cloudflare.ipv4_cidr_blocks}"]
    }

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket" "panelapp_scripts" {
  bucket = "${var.stack}-${var.env_name}-${var.account_id}-${var.region}-panelap-scripts"

  policy = ""

  acl = "private"

  versioning {
    enabled = true
  }

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_scripts")
  )}"
}

resource "aws_s3_bucket" "panelapp_cloudfront_logs" {
  bucket = "${var.stack}-${var.env_name}-${var.account_id}-${var.region}-opslogs"

  acl = "private"

  versioning {
    enabled = false
  }

  lifecycle_rule {
    id      = "remove_after_3d"
    enabled = true
    expiration {
      days = 3
    }
    prefix = "cloudfront-logs"
  }

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_opslogs")
  )}"
}

resource "aws_s3_bucket_public_access_block" "statics" {
  bucket = "${aws_s3_bucket.panelapp_statics.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "media" {
  bucket = "${aws_s3_bucket.panelapp_media.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "scripts" {
  bucket = "${aws_s3_bucket.panelapp_scripts.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "cloudfront_logs" {
  bucket = "${aws_s3_bucket.panelapp_cloudfront_logs.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
