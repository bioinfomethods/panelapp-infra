module "github-oidc" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "~> 2.2.1"

  create_oidc_provider = true
  create_oidc_role     = true

  repositories = ["bioinfomethods/panelapp", "bioinfomethods/panelapp-infra"]

  # TODO - Review the policies attached to this OIDC role intended for DevOps managed using Terraform
  # Whilst custom policies is arguably a better practice (principle of least privileged), the following is easier to
  # manage since these policies are managed by AWS.
  oidc_role_attach_policies = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonCognitoReadOnly",
    "arn:aws:iam::aws:policy/CloudFrontFullAccess",
    "arn:aws:iam::aws:policy/ElasticLoadBalancingReadOnly",
    "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
  ]
}
