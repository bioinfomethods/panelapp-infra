resource "cloudflare_record" "cdn" {
  count   = "${!var.create_cloudfront ? 1 : 0}"
  domain  = "${var.cloudflare_zone}"
  name    = "${var.cloudflare_record}"
  value   = "${var.public_dns_zone_name}"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "static" {
  count   = "${!var.create_cloudfront ? 1 : 0}"
  domain  = "${var.cloudflare_zone}"
  name    = "${var.cloudflare_static_files_record}"
  value   = "${aws_s3_bucket.panelapp_statics.bucket_regional_domain_name}"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_page_rule" "static" {
  count    = "${!var.create_cloudfront ? 1 : 0}"
  zone     = "${var.cloudflare_zone}"
  target   = "${var.cloudflare_record}.${var.cloudflare_zone}/static/*"
  priority = 1

  actions {
    resolve_override     = "${cloudflare_record.static.hostname}"
    host_header_override = "${aws_s3_bucket.panelapp_statics.bucket_regional_domain_name}"
  }
}

resource "cloudflare_record" "media" {
  count   = "${!var.create_cloudfront ? 1 : 0}"
  domain  = "${var.cloudflare_zone}"
  name    = "${var.cloudflare_media_files_record}"
  value   = "${aws_s3_bucket.panelapp_media.bucket_regional_domain_name}"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_page_rule" "media" {
  count    = "${!var.create_cloudfront ? 1 : 0}"
  zone     = "${var.cloudflare_zone}"
  target   = "${var.cloudflare_record}.${var.cloudflare_zone}/media/*"
  priority = 1

  actions {
    resolve_override     = "${cloudflare_record.media.hostname}"
    host_header_override = "${aws_s3_bucket.panelapp_media.bucket_regional_domain_name}"
  }
}
