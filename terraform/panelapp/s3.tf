resource "aws_s3_bucket" "panelapp_statics" {
  bucket = "${var.stack}-${var.env_name}-${var.account_id}-${var.region}-panelapp-statics"

  acl = "public-read"

  versioning {
    enabled = true
  }

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_static")
  )}"
}

resource "aws_s3_bucket_policy" "panelapp_statics" {
  bucket = "${aws_s3_bucket.panelapp_statics.id}"
  policy = "${data.aws_iam_policy_document.s3_policy.json}"
}

data "aws_iam_policy_document" "s3_policy" {
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

resource "aws_s3_bucket" "panelapp_media" {
  bucket = "${var.stack}-${var.env_name}-${var.account_id}-${var.region}-panelapp-media"

  policy = ""

  versioning {
    enabled = true
  }

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_media")
  )}"
}
