resource "aws_lb" "panelapp" {
  name               = "panelapp-elb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.panelapp_elb.id]
  subnets         = data.terraform_remote_state.infra.outputs.public_subnets

  # subnet_mapping {
  #   subnets = "${data.terraform_remote_state.infra.private_subnets}"
  # }

  tags = merge(
    var.default_tags,
    tomap({"Name": "panelapp_elb"})
  )
}

data "aws_ip_ranges" "cloudfront_global" {
  regions  = ["global"]
  services = ["cloudfront"]
}

resource "aws_security_group_rule" "panelapp_egress_cloudfront" {
  count     = var.create_cloudfront ? 1 : 0
  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  cidr_blocks = data.aws_ip_ranges.cloudfront_global.cidr_blocks

  # cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.panelapp_elb.id
  description       = "egress for panelapp"
}


resource "aws_security_group_rule" "self_egress" {
  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"
  self      = true

  security_group_id = aws_security_group.panelapp_elb.id
  description       = "egress for panelapp"
}

resource "aws_security_group_rule" "panelapp_ingress_cloudfront" {
  count     = var.create_cloudfront ? 1 : 0
  type      = "ingress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  # cidr_blocks = ["0.0.0.0/0"]

  cidr_blocks = data.aws_ip_ranges.cloudfront_global.cidr_blocks
  security_group_id = aws_security_group.panelapp_elb.id
  description       = "ingress for panelapp"
}

resource "aws_security_group_rule" "panelapp_ingress_cloudflare" {
  count     = !var.create_cloudfront ? 1 : 0
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  cidr_blocks = [data.cloudflare_ip_ranges.cloudflare.ipv4_cidr_blocks]
  security_group_id = aws_security_group.panelapp_elb.id
  description       = "ingress for Panelapp from Cloudflare"
}

resource "aws_security_group_rule" "self_ingress" {
  type      = "ingress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"
  self      = true

  security_group_id = aws_security_group.panelapp_elb.id
  description       = "ingress for panelapp"
}

resource "aws_security_group" "panelapp_elb" {
  name        = "panelapp_elb"
  description = "default group for panelapp load balancer"
  vpc_id      = data.terraform_remote_state.infra.outputs.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.default_tags,
    tomap({"Name": "panelapp_elb_sec"})
  )
}

resource "aws_lb_target_group" "panelapp_app_web" {
  name        = "panelapp-app-web"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.terraform_remote_state.infra.outputs.vpc_id

  health_check {
    path = "/version/"
  }
}

resource "aws_lb_listener" "panelapp_app_web" {
  load_balancer_arn = aws_lb.panelapp.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.terraform_remote_state.infra.outputs.global_cert

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.panelapp_app_web.arn
  }
}
