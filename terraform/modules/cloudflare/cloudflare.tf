resource "cloudflare_record" "cdn" {
  count   = var.create_cloudflare ? 1 : 0
  zone_id = var.cloudflare_zone
  name    = var.cloudflare_record
  value   = var.public_dns_zone_name
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "static" {
  count   = var.create_cloudflare ? 1 : 0
  zone_id = var.cloudflare_zone
  name    = var.cloudflare_static_files_record
  value   = var.static_bucket
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_page_rule" "static" {
  count   = var.create_cloudflare ? 1 : 0
  zone_id = var.cloudflare_zone
  target  = "${var.cloudflare_record}.${var.cloudflare_zone}/static/*"

  actions {
    resolve_override     = cloudflare_record.static[0].hostname
    host_header_override = var.static_bucket
  }
}

resource "cloudflare_record" "media" {
  count   = var.create_cloudflare ? 1 : 0
  zone_id = var.cloudflare_zone
  name    = var.cloudflare_media_files_record
  value   = var.media_bucket
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_page_rule" "media" {
  count   = var.create_cloudflare ? 1 : 0
  zone_id = var.cloudflare_zone
  target  = "${var.cloudflare_record}.${var.cloudflare_zone}/media/*"

  actions {
    resolve_override     = cloudflare_record.media[0].hostname
    host_header_override = var.media_bucket
  }
}
