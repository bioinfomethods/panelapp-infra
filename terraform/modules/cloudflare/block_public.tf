locals {
  ips = join(" and ip.src ne ", var.whitelisted_ips)
  hostname = "${var.cloudflare_record}.${var.cloudflare_zone}"
}

resource "cloudflare_ruleset" "block_public_access" {
  count       = var.create_cloudflare ? 1 : 0
  kind        = "zone"
  name        = "block_public_access"
  phase       = "magic_transit"
  zone_id     = var.cloudflare_zone
  description = "BlockPublicAccess-${local.hostname}"
  rules {
    action      = "block"
    expression  = "(ip.src ne ${local.ips} and http.host eq \"${local.hostname}\")"
    description = "BlockPublicAccess-${local.hostname}"
    enabled     = var.block_public_access
  }
}

# customise 1000 cloudflare error page
#resource "cloudflare_custom_pages" "holding_page" {
#  count = "${var.create_cloudflare ? 1 : 0}"
#  zone  = "${var.cloudflare_zone}"
#  type  = "1000_errors"
#  url   = "https://holding page todo"
#  state = "customized"
#}
