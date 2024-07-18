resource "aws_cloudfront_origin_access_identity" "panelapp_s3" {
  count   = var.create_cloudfront ? 1 : 0
  comment = "access identity to access s3"
}

resource "aws_cloudfront_distribution" "panelapp_distribution" {
  count   = var.create_cloudfront ? 1 : 0
  aliases = [var.cdn_alis]

  origin {
    domain_name = aws_s3_bucket.panelapp_statics.bucket_regional_domain_name
    origin_path = ""
    origin_id   = "S3-panelapp-statics"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.panelapp_s3[0].cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = aws_s3_bucket.panelapp_media.bucket_regional_domain_name
    origin_path = ""
    origin_id   = "S3-panelapp_media"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.panelapp_s3[0].cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = aws_lb.panelapp.dns_name
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
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
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
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
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

  ordered_cache_behavior {
    path_pattern           = "media/*"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-panelapp_media"
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

    acm_certificate_arn = data.terraform_remote_state.infra.outputs.global_cert

    ssl_support_method = "sni-only"
  }

  tags = merge(
    var.default_tags,
    tomap({"Name": "panelapp_cdn"})
  )
}
