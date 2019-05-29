module "autoscaling" {
  source = "../modules/autoscaling"

  image_id = "ami-0009a33f033d8b7b6"
  name     = "panelapp_test"

  lc_name = "panelapp"

  instance_type       = "t2.micro"
  vpc_zone_identifier = ["${data.terraform_remote_state.infra.private_subnets}"]
  max_size            = 1
  min_size            = 1
  desired_capacity    = 1
  health_check_type   = "EC2"

  security_groups = ["${module.aurora.aurora_security_group}", "${module.autoscaling.psql_security_id}"]

  user_data            = "${module.autoscaling.user_data}"
  iam_instance_profile = "${module.autoscaling.ssm_role}"
}
