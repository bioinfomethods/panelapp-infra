module "autoscaling" {
  source = "../modules/autoscaling"

  image_id = "ami-0009a33f033d8b7b6"
  name     = "panelapp_test"

  lc_name    = "panelapp"
  create_asg = false
  create_lc  = false

  instance_type       = "t2.micro"
  vpc_zone_identifier = ["${data.terraform_remote_state.infra.private_subnets}"]
  vpc_id              = "${local.vpc_id}"
  max_size            = 0
  min_size            = 0
  desired_capacity    = 0
  health_check_type   = "EC2"

  security_groups = ["${module.aurora.aurora_security_group}", "${module.autoscaling.psql_security_id}"]

  user_data            = "${module.autoscaling.user_data}"
  iam_instance_profile = "${module.autoscaling.ssm_role}"
}
