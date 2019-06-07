resource "aws_lb" "panelapp" {
  name               = "panelapp-elb"
  internal           = false
  load_balancer_type = "application"

  security_groups = ["${aws_security_group.panelapp_elb.id}"]
  subnets         = ["${data.terraform_remote_state.infra.public_subnets}"]

  # subnet_mapping {
  #   subnets = "${data.terraform_remote_state.infra.private_subnets}"
  # }

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_elb")
  )}"
}

data "aws_ip_ranges" "european_us_cloudfront" {
  regions  = ["eu-west-1", "eu-central-1", "eu-west-2", "eu-west-3", "eu-north-1", "us-east-1", "us-east-2", "us-east-1", "us-west-1", "us-west-2"]
  services = ["cloudfront"]
}

resource "aws_security_group_rule" "panelapp_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.panelapp_elb.id}"
  description       = "egress for panelapp"
}

resource "aws_security_group_rule" "panelapp_ingress" {
  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  # cidr_blocks       = ["${data.aws_ip_ranges.european_us_cloudfront.cidr_blocks}"]
  security_group_id = "${aws_security_group.panelapp_elb.id}"
  description       = "egress for panelapp"
}

resource "aws_security_group" "panelapp_elb" {
  name        = "panelapp_elb"
  description = "default group for panelapp load balancer"
  vpc_id      = "${data.terraform_remote_state.infra.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_elb_sec")
  )}"
}

resource "aws_lb_target_group" "panelapp_app_web" {
  name        = "panelapp-app-web"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${data.terraform_remote_state.infra.vpc_id}"

  health_check {
    path = "/version/"
  }
}

resource "aws_lb_listener" "panelapp_app_web" {
  load_balancer_arn = "${aws_lb.panelapp.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${data.terraform_remote_state.infra.regional_cert}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.panelapp_app_web.arn}"
  }
}
