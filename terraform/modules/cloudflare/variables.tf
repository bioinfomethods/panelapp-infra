variable "create_cloudflare" {
  description = "To wether create cloudflare"
}

variable "cloudflare_zone" {
  description = "cloudflare zone to manage"
}

variable "public_dns_zone_name" {
  description = "internal zone to point to"
}

variable "cloudflare_record" {
  description = "cloudflare record to add"
}

variable "cloudflare_static_files_record" {
  description = "static files record to s3"
}

variable "static_bucket" {
  description = "static bucket dns"
}

variable "cloudflare_media_files_record" {
  description = "media files record to s3"
}

variable "media_bucket" {
  description = "media bucket dns"
}

variable "block_public_access" {
  default = false
}

variable "whitelisted_ips" {
  type    = "list"
  default = ["127.0.0.1"]
}
