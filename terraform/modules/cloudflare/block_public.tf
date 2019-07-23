locals {
  ips      = "${join(" and ip.src ne ", var.whitelisted_ips)}"
  hostname = "${var.cloudflare_record}.${var.cloudflare_zone}"
}

resource "cloudflare_filter" "block_public_access" {
  count       = "${var.create_cloudflare ? 1 : 0}"
  zone        = "${var.cloudflare_zone}"
  description = "BlockPublicAccess-${local.hostname}"
  expression  = "(ip.src ne ${local.ips} and http.host eq \"${local.hostname}\")"
}

resource "cloudflare_firewall_rule" "block_pubilc_access" {
  count       = "${var.create_cloudflare ? 1 : 0}"
  zone        = "${var.cloudflare_zone}"
  description = "BlockPublicAccess"
  filter_id   = "${cloudflare_filter.block_public_access.id}"
  action      = "block"
  paused      = "${! var.block_public_access}"
}
