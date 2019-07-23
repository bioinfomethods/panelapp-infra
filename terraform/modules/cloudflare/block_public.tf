locals {
  hostname = "${var.cloudflare_record}.${var.cloudflare_zone}"
}

resource "cloudflare_filter" "block_public_access" {
  count       = "${var.create_cloudflare ? 1 : 0}"
  zone        = "${var.cloudflare_zone}"
  description = "BlockPublicAccess-${local.hostname}"
  expression  = "(ip.src ne 81.134.251.212 and ip.src ne 83.151.220.174 and http.host eq \"${local.hostname}\")"
}

resource "cloudflare_firewall_rule" "block_pubilc_access" {
  count       = "${var.create_cloudflare ? 1 : 0}"
  zone        = "${var.cloudflare_zone}"
  description = "BlockPublicAccess"
  filter_id   = "${cloudflare_filter.block_public_access.id}"
  action      = "block"
  paused      = "${!var.block_public_access}"
}
