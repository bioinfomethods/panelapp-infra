resource "aws_launch_configuration" "this" {
  count = var.create_lc

  # name_prefix                 = "${coalesce(var.lc_name, var.name)}-"
  image_id                    = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  security_groups             = [var.security_groups]
  associate_public_ip_address = var.associate_public_ip_address
  user_data                   = templatefile("${path.module}/templates/user_data.tpl", {
    image_name       = var.image_name
    image_tag        = var.image_tag
    database_host    = var.database_host
    database_port    = var.database_port
    database_name    = var.database_name
    database_user    = var.database_user
    env              = var.env_name
    db_password      = "lorenzo knows"
    aws_region       = var.aws_region
    panelapp_statics = var.panelapp_statics
    panelapp_media   = var.panelapp_media
    cdn_domain_name  = var.cdn_domain_name
  })
  enable_monitoring           = var.enable_monitoring
  ebs_optimized               = var.ebs_optimized
  iam_instance_profile        = var.iam_instance_profile

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  count = var.create_asg && ! var.create_asg_with_initial_lifecycle_hook ? 1 : 0

  name                 = "mgt-${var.name}"
  launch_configuration = var.create_lc ? element(concat(aws_launch_configuration.this.*.name, list("")), 0) : var.launch_configuration
  vpc_zone_identifier  = [var.vpc_zone_identifier]
  max_size             = var.max_size
  min_size             = var.min_size
  desired_capacity     = var.desired_capacity
  health_check_type    = var.health_check_type

  default_cooldown     = var.default_cooldown
  force_delete         = var.force_delete
  termination_policies = var.termination_policies
  suspended_processes  = var.suspended_processes

  tags = [
    {
      key                 = "Name"
      value               = "mgt"
      propagate_at_launch = true
    },
  ]

  # {
  #   key                 = "Stack"
  #   value               = "${var.stack}"
  #   propagate_at_launch = true
  # },
  # {
  #   key                 = "Env"
  #   value               = "${lookup(var.default_tags, "Env")}"
  #   propagate_at_launch = true
  # }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this_with_initial_lifecycle_hook" {
  count = var.create_asg && var.create_asg_with_initial_lifecycle_hook ? 1 : 0

  # name_prefix          = "${join("-", compact(list(coalesce(var.asg_name, var.name), var.recreate_asg_when_lc_changes ? element(concat(random_pet.asg_name.*.id, list("")), 0) : "")))}-"
  launch_configuration = var.create_lc ? element(concat(aws_launch_configuration.this.*.name, list("")), 0) : var.launch_configuration
  vpc_zone_identifier  = [var.vpc_zone_identifier]
  max_size             = var.max_size
  min_size             = var.min_size
  desired_capacity     = var.desired_capacity
  health_check_type    = var.health_check_type

  default_cooldown     = var.default_cooldown
  force_delete         = var.force_delete
  termination_policies = var.termination_policies
  suspended_processes  = var.suspended_processes

  initial_lifecycle_hook {
    name                 = var.initial_lifecycle_hook_name
    lifecycle_transition = var.initial_lifecycle_hook_lifecycle_transition
    role_arn             = var.initial_lifecycle_hook_role_arn
  }

  lifecycle {
    create_before_destroy = true
  }
}
