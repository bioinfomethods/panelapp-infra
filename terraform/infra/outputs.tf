output "public_dns_zone" {
  description = "Public DNS Zone ID"
  value       = module.site.public_dns_zone
}

output "public_dns_zone_ns" {
  description = "List of NS of the public DNS Zone"
  value       = module.site.public_dns_zone_ns
}

output "public_dns_zone_name" {
  description = "Public DNS Zone name"
  value       = module.site.public_dns_zone_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.public_subnets
}

output "regional_cert" {
  description = "Regional Certificate ARN"
  value       = module.acm.regional_cert
}

output "global_cert" {
  description = "Global Certificate ARN"
  value       = module.acm.global_cert
}

output "artifacts_bucket" {
  description = "ID of the artifacts S3 bucket"
  value       = module.site.artifacts_bucket
}

output "terraform_s3_bucket_id" {
  description = "ID of the Terraform state S3 bucket"
  value       = module.site.terraform_bucket
}

output "kms_arn" {
  value = module.site.site_key
}

output "rds_shared_kms_arn" {
  value = module.site.rds_shared_key
}

output "ecr_repo_web_id" {
  value = aws_ecr_repository.repo_web.registry_id
}

output "panelapp_web_image" {
  value = aws_ecr_repository.repo_web.repository_url
}

output "ecr_repo_worker_id" {
  value = aws_ecr_repository.repo_worker.registry_id
}

output "panelapp_worker_image" {
  value = aws_ecr_repository.repo_worker.repository_url
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN"
  value       = module.github-oidc.oidc_provider_arn
}

output "github_oidc_role" {
  description = "CICD GitHub role."
  value       = module.github-oidc.oidc_role
}
