module "autoscaling" {
  source = "../modules/autoscaling"

  name = "panelapp_test"

  lc_name    = "panelapp"
  create_asg = true
  create_lc  = true

  instance_type       = "t2.micro"
  vpc_zone_identifier = ["${data.terraform_remote_state.infra.private_subnets}"]
  vpc_id              = "${local.vpc_id}"
  max_size            = "${var.EC2_mgmt_count}"
  min_size            = "${var.EC2_mgmt_count}"
  desired_capacity    = "${var.EC2_mgmt_count}"
  health_check_type   = "EC2"

  security_groups = ["${module.aurora.aurora_security_group}", "${module.autoscaling.psql_security_id}"]

  user_data            = "${module.autoscaling.user_data}"
  iam_instance_profile = "${module.autoscaling.ssm_role}"
  aritfacts_bucket     = "${data.terraform_remote_state.infra.artifacts_bucket}"
  kms_arn              = "${data.terraform_remote_state.infra.kms_arn}"
}
