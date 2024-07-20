## This file contains all installation-specific parameters to run both Terraform ./panelapp and ./infra components.
## Please note the configuration for the ./shared project is different
## Please amend it and use it when running terraform, specifying -var-file=<path-to-tfvars>
## (or, alternatively, rename it terraform.tfvars and copy it in both ./panelapp and ./infra so Terraform will pick it up automatically)


# Name of the environment (e.g. "prod")
env_name = "<env-name>"

# AWS Account ID (e.g. "1234567890123"
account_id = "<account-id>"

# AWS Account ID for ECR (may be the same as the previous one or different)
# Only used if you enable GitLab runners
master_account = "<master-account-id>"

# Should be the same as account_id
trusted_account = "<account-id>"

# AWS Region (e.g. "eu-west-2")
region = "<region>"

# Set to true if Route53 public hosted zone does not already exist
create_public_dns_zone = false

# Set this to the Route53 public hosted zone ID (regardless of whether it already exists or created by terraform)
public_route53_zone = "setme"

# DNS Zone of the AWS application (e.g. "panelapp.mydomain.com")
public_dns_zone_name = "<public-dns-domain>"

# Name of the Terraform State bucket. It must match the name defined in backend.conf
terraform_state_s3_bucket = "panelapp-<env>-<account-id>-<region>-terraform-state"

# CIDR of the VPC and subnet masks (change it as suitable)
cidr = "172.16.5.0/26"
public_subnets = ["172.16.5.0/28", "172.16.5.16/28"]
private_subnets = ["172.16.5.32/28", "172.16.5.48/28"]

# Name of the SQS Queue
sqs_name = "pannelapp"
dns_record = ""

# Default Tags for AWS resources. Change it into anything suitable for you.
default_tags = {
  "Stack" = "panelapp"
  "Env"   = "<env>"
}

# Create GitHub runners?
create_runner_terraform = false

########
## CDN
########

# True: Use CloudFront CDN. False: Use CloudFlare CDN
create_cloudfront = false


# Fully-Qualified DNS name used by the CDN (usually different from the domain defined above)
# (note this is redundant with the two settings below, as it must match <cloudflare_record>.<cloudflare_zone> - we need to improve this)
cdn_alias = "<cdn-domain>"

# Host name in the domain below
cloudflare_record = "<hostname>"
# Domain name
cloudflare_zone = "<dns-domain>"

# CloudFlare DNS host record for static and media files (change to any suitable, valid hostname)
cloudflare_static_files_record = "prod-static-panelapp"
cloudflare_media_files_record  = "prod-media-panelapp"

# CDN (CloudFront or CloudFlare) to ELB request header name
waf_acl_cf_req_header_name = "cf_req_header"

########################
## Fargate/Application
########################

# Number of instances of Web AND Worker containers.
# To scale, increase replicas rather than making them bigger or increasing gunocorn worker threads
# A limitation of the current implementation is the number of Worker and Web containers must be the same
panelapp_replica = 2


# Fargate tasks resources
# task_cpu and task_memory cannot be arbitrary. See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html#fargate-tasks-size
# A limitation of the current implementation is all Fargate tasks use the same settings
task_cpu = 2048
task_memory = 4096

# CloudWatch log retention (days)
log_retention = 30

# Number of worker thread of Gunicorn web server, in each Web container
gunicorn_workers = 8
# Gunicorn web server timeout
application_connection_timeout = 300

# path of the Django Admin site. Change so something as unpredictable as possible (security by obscurity ;) )
admin_url = "hideme/"

# Default FROM email address and official contact email address
default_email  = "panelapp@mydomain.com"
panelapp_email = "panelapp@mydomain.com"

######################
## Aurora PostgreSQL
######################

# Number of Aurora instances (increase to 2 for HA)
aurora_replica = 1

# Size of Aurora instances
db_instance_class = "db.r5.large"

###################
## Other settings
###################

# Management box. Change to 1 to start the management box EC2 instance
EC2_mgmt_count = 0

# Datadog integration
enable_datadog = false
# Datadog integration ID
datadog_aws_integration_external_id = ""
