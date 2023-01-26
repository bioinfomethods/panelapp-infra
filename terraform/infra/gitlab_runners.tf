/*
module "gitlab-runners" {
  source = "../modules/gitlab-runners"

  stack                   = "${var.stack}"
  vpc_id                  = "${module.vpc.vpc_id}"
  ecs_subnets             = "${module.vpc.private_subnets}"
  site_kms_key            = "*"                                                                                                              # FIXME"${module.site.site_key}"
  default_tags            = "${var.default_tags}"
  gitlab_runner_token     = "arn:aws:ssm:${var.region}:${var.account_id}:parameter/${var.stack}/${var.env_name}/REGISTRATION_TOKEN"
  cloudflare_email        = "arn:aws:ssm:${var.region}:${var.account_id}:parameter/${var.stack}/${var.env_name}/cloudflare/CLOUDFLARE_EMAIL"
  cloudflare_token        = "arn:aws:ssm:${var.region}:${var.account_id}:parameter/${var.stack}/${var.env_name}/cloudflare/CLOUDFLARE_TOKEN"
  app_image               = "${var.master_account}.dkr.ecr.${var.region}.amazonaws.com/gitlab-runner:${var.gitlab_runner_image_tag}"
  create_runner_terraform = "${var.create_runner_terraform}"
  app_region              = "${var.region}"
  additional_runner_tag   = "TF_${var.stack}_${var.env_name}"
  master_account          = "${var.master_account}"
}
*/
