output "terraform_bucket" {
  description = "ID of the Terraform state S3 bucket"
  value       = aws_s3_bucket.terraform.id
}

output "artifacts_bucket" {
  description = "ID of the artifacts S3 bucket"
  value       = aws_s3_bucket.artifacts.id
}

output "dns_delegation_set" {
  description = "Route53 Delegation Set ID"
  value       = aws_route53_delegation_set.site.id
}

output "public_dns_zone" {
  description = "Public DNS Zone ID"
  value = coalesce(join("", aws_route53_zone.public.*.id), "not_created")
}

output "public_dns_zone_ns" {
  description = "List of NS of the public DNS Zone"
  value       = aws_route53_delegation_set.site.name_servers
}

output "public_dns_zone_name" {
  description = "Public DNS Zone name"
  value = coalesce(join("", aws_route53_zone.public.*.name), "not_created")
}

output "site_key" {
  value = aws_kms_key.site.arn
}

output "rds_shared_key" {
  value = join("", aws_kms_key.rds_shared.*.arn)
}
