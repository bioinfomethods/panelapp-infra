module "cloudflare" {
  source = "../modules/cloudflare"

  create_cloudflare              = !var.create_cloudfront
  cloudflare_zone                = var.cloudflare_zone
  cloudflare_record              = var.cloudflare_record
  public_dns_zone_name           = var.public_dns_zone_name
  cloudflare_static_files_record = var.cloudflare_static_files_record
  static_bucket                  = aws_s3_bucket.panelapp_statics.bucket_regional_domain_name
  cloudflare_media_files_record  = var.cloudflare_media_files_record
  media_bucket                   = aws_s3_bucket.panelapp_media.bucket_regional_domain_name
  block_public_access            = var.block_public_access
  whitelisted_ips                = var.whitelisted_ips
}
