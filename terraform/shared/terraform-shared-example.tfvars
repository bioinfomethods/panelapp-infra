## This file contains all installation-specific parameters to run the Terrafrom ./shared component only.
## Please note the configuration for ./panelapp and ./infra projects is different
## Please amend it and use it when running terraform, specifying -var-file=<path-to-tfvars>
## (or, alternatively, rename it terraform-.tfvars so Terraform will pick it up automatically)

# Not really an "environment" name in this case. This is not supposed to be modified
env_name = "shared"

# AWS Account ID (e.g. "1234567890123"
account_id = "<account-id>"

# AWS Region (e.g. "eu-west-2")
region = "<region>"

# Set to true if Route53 public hosted zone does not already exist
create_public_dns_zone = false

# Set this to the Route53 public hosted zone ID (regardless of whether it already exists or created by terraform)
public_route53_zone = "setme"

# DNS Zone of the AWS application (e.g. "panelapp.mydomain.com")
public_dns_zone_name = "<public-dns-domain>"

# Name of the Terraform State bucket. It must match the name defined in backend.conf
terraform_state_s3_bucket = "panelapp-shared-<account-id>-<region>-terraform-state"

# Default Tags for AWS resources. Change it into anything suitable for you.
default_tags = {
  "Stack"    = "panelapp"
  "Env"      = "shared"
}

# AWS Account ID for ECR (may be the same as the previous one or different)
# Only used if you enable GitLab runners
master_account = "<master-account-id>"
