module "mgt" {
  source = "../modules/mgt"

  name = "panelapp-${var.env_name}"

  lc_name    = "panelapp"
  create_asg = true
  create_lc  = true

  instance_type       = "t2.micro"
  vpc_zone_identifier = [data.terraform_remote_state.infra.private_subnets]
  vpc_id              = local.vpc_id
  max_size            = var.EC2_mgmt_count
  min_size            = var.EC2_mgmt_count
  desired_capacity    = var.EC2_mgmt_count
  health_check_type   = "EC2"

  security_groups = [module.aurora.aurora_security_group, module.mgt.psql_security_id]

  user_data            = module.mgt.user_data
  iam_instance_profile = module.mgt.ssm_role
  aritfacts_bucket     = data.terraform_remote_state.infra.artifacts_bucket
  kms_arn              = data.terraform_remote_state.infra.kms_arn

  image_name       = "${var.panelapp_image_repo}/panelapp-web"
  image_tag        = var.image_tag
  #database_host    = "${module.aurora.writer_endpoint}"
  #database_port    = "${module.aurora.port}"
  #database_name    = "${module.aurora.database_name}"
  #database_user    = "${module.aurora.database_user}"
  database_host    = module.aurora.writer_endpoint
  database_port    = "5432"
  database_name    = "panelapp"
  database_user    = "panelapp"
  db_password      = "lorenzo knows"
  aws_region       = var.region
  panelapp_statics = aws_s3_bucket.panelapp_statics.id
  panelapp_media   = aws_s3_bucket.panelapp_media.id
  cdn_domain_name  = var.cdn_alis
  env_name         = var.env_name
}
