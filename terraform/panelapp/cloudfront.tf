resource "aws_cloudfront_distribution" "panelapp_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.panelapp_statics.bucket_regional_domain_name}"
    origin_id   = "S3-panelapp-statics"

    # s3_origin_config {
    #   origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
    # }
  }

  enabled = true

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "allow-all"
    target_origin_id       = "S3-panelapp-statics"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
