output "terraform_bucket" {
  description = "ID of the Terraform state S3 bucket"
  value       = aws_s3_bucket.terraform.id
}

output "public_dns_zone" {
  description = "Public DNS Zone ID"
  value = coalesce(join("", aws_route53_zone.public.*.id), "not_created")
}

output "public_dns_zone_ns" {
  description = "List of NS of the public DNS Zone"
  value       = aws_route53_delegation_set.shared.name_servers
}

output "public_dns_zone_name" {
  description = "Public DNS Zone name"
  value = coalesce(join("", aws_route53_zone.public.*.name), "not_created")
}

output "shared_key" {
  value = aws_kms_key.shared.arn
}
