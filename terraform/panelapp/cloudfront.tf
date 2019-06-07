resource "aws_cloudfront_distribution" "panelapp_distribution" {
  aliases = ["test.panelapp-cloud.genomicsengland.co.uk"]

  origin {
    domain_name = "${aws_s3_bucket.panelapp_statics.bucket_regional_domain_name}"
    origin_path = ""
    origin_id   = "S3-panelapp-statics"

    # s3_origin_config {
    #   origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
    # }
  }

  origin {
    domain_name = "${aws_lb.panelapp.dns_name}"
    origin_path = ""
    origin_id   = "panelapp-elb"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1"]
    }
  }

  enabled = true

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "panelapp-elb"

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    # min_ttl     = 0
    # default_ttl = 0
    # max_ttl     = 0


    # compress = true

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern           = "static/*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-panelapp-statics"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false

    acm_certificate_arn = "${data.terraform_remote_state.infra.global_cert}"

    ssl_support_method = "sni-only"
  }
}
