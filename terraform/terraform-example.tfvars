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
# E.g. Z0012345678ABCDEFGHIJ
# public_route53_zone = "setme"
public_dns_zone = "setme"

# DNS Zone of the AWS application (e.g. "panelapp.mydomain.com")
public_dns_zone_name = "<public-dns-domain>"

# Name of the Terraform State shared bucket. It must match the name defined in backend.conf
terraform_shared_state_s3_bucket = "panelapp-shared-<account-id>-<region>-terraform-state"

# Name of the Terraform State infra bucket. It must match the name defined in backend.conf
terraform_infra_state_s3_bucket = "panelapp-test-<account-id>-<region>-terraform-state"

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

# CDN (CloudFront or CloudFlare) to ELB request header name, shouldn't need to change
waf_acl_cf_req_header_name = "cf_req_header"

########################
## Fargate/Application
########################

# Number of instances of Web AND Worker containers.
# To scale, increase replicas rather than making them bigger or increasing gunicorn worker threads
# A limitation of the current implementation is the number of Worker and Web containers must be the same
panelapp_replica_web = 2
panelapp_replica_worker = 2


# Fargate tasks resources
# task_cpu and task_memory cannot be arbitrary. See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html#fargate-tasks-size
# A limitation of the current implementation is all Fargate tasks use the same settings
task_cpu = 2048
task_memory = 4096
worker_task_cpu = 512
worker_task_memory = 1024

# CloudWatch log retention (days)
log_retention = 30

# Number of worker thread of Gunicorn web server, in each Web container
gunicorn_workers = 8
# Gunicorn web server timeout
application_connection_timeout = 300

# path of the Django Admin site. Change so something as unpredictable as possible (security by obscurity ;) )
admin_url = "hideme/"
smtp_server = "email-smtp.ap-southeast-2.amazonaws.com"

# Django admin user email and password, obviously change it to something secure
admin_email = "test@test.com"
admin_secret = "secret"

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

# Turn on Aurora RDS Enhanced Monitoring
mon_interval = 0

# Turn on Aurora RDS Performance Insights
performance_insights_enabled = false

# Number of days to retain performance insights metrics, more than 7 is not free
performance_insights_retention_period = 7

# Flag to create a bastion host to access the RDS cluster
create_bastion_host = false

# Name of the SSH key pair to access the bastion host
# To create new key pair, see https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html#having-ec2-create-your-key-pair
bastion_host_key_name = "id_ed25519"

###################
## Other settings
###################
# Cognito suffix when: "Domain already associated with another user pool"
cognito_suffix = ""

# Management box. Change to 1 to start the management box EC2 instance
EC2_mgmt_count = 0

# Datadog integration
enable_datadog = false
# Datadog integration ID
datadog_aws_integration_external_id = ""

# Used for deployment and release process of the application
image_tag = "latest"
