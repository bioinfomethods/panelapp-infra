resource "aws_launch_configuration" "this" {
  count = "${var.create_lc}"

  # name_prefix                 = "${coalesce(var.lc_name, var.name)}-"
  image_id                    = "${var.image_id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${var.security_groups}"]
  associate_public_ip_address = "${var.associate_public_ip_address}"
  user_data                   = "${data.template_file.user_data.rendered}"
  enable_monitoring           = "${var.enable_monitoring}"
  ebs_optimized               = "${var.ebs_optimized}"
  iam_instance_profile        = "${var.iam_instance_profile}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  count = "${var.create_asg && !var.create_asg_with_initial_lifecycle_hook ? 1 : 0}"

  # name_prefix          = "${join("-", compact(list(coalesce(var.asg_name, var.name), var.recreate_asg_when_lc_changes ? element(concat(random_pet.asg_name.*.id, list("")), 0) : "")))}-"
  launch_configuration = "${var.create_lc ? element(concat(aws_launch_configuration.this.*.name, list("")), 0) : var.launch_configuration}"
  vpc_zone_identifier  = ["${var.vpc_zone_identifier}"]
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  desired_capacity     = "${var.desired_capacity}"
  health_check_type    = "${var.health_check_type}"

  default_cooldown     = "${var.default_cooldown}"
  force_delete         = "${var.force_delete}"
  termination_policies = "${var.termination_policies}"
  suspended_processes  = "${var.suspended_processes}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this_with_initial_lifecycle_hook" {
  count = "${var.create_asg && var.create_asg_with_initial_lifecycle_hook ? 1 : 0}"

  # name_prefix          = "${join("-", compact(list(coalesce(var.asg_name, var.name), var.recreate_asg_when_lc_changes ? element(concat(random_pet.asg_name.*.id, list("")), 0) : "")))}-"
  launch_configuration = "${var.create_lc ? element(concat(aws_launch_configuration.this.*.name, list("")), 0) : var.launch_configuration}"
  vpc_zone_identifier  = ["${var.vpc_zone_identifier}"]
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  desired_capacity     = "${var.desired_capacity}"
  health_check_type    = "${var.health_check_type}"

  default_cooldown     = "${var.default_cooldown}"
  force_delete         = "${var.force_delete}"
  termination_policies = "${var.termination_policies}"
  suspended_processes  = "${var.suspended_processes}"

  initial_lifecycle_hook {
    name                 = "${var.initial_lifecycle_hook_name}"
    lifecycle_transition = "${var.initial_lifecycle_hook_lifecycle_transition}"
    role_arn             = "${var.initial_lifecycle_hook_role_arn}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
