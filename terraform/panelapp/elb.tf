resource "aws_lb" "panelapp" {
  name               = "panelapp-elb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.panelapp_elb.id]
  subnets = data.terraform_remote_state.infra.outputs.public_subnets

  # subnet_mapping {
  #   subnets = "${data.terraform_remote_state.infra.private_subnets}"
  # }

  tags = merge(
    var.default_tags,
    tomap({ "Name" : "panelapp_elb" })
  )
}

# data "aws_ip_ranges" "cloudfront_global" {
#   regions  = ["global"]
#   services = ["cloudfront"]
# }

data "aws_ec2_managed_prefix_list" "cloudfront_global" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group_rule" "panelapp_egress_cloudfront" {
  count     = var.create_cloudfront ? 1 : 0
  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront_global.id]

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

# ELB should only be allowed to be accessed from CloudFront
resource "aws_security_group_rule" "panelapp_ingress_cloudfront" {
  count     = var.create_cloudfront ? 1 : 0
  type      = "ingress"
  from_port = 0
  to_port   = 65535
  protocol = "tcp"

#   cidr_blocks = ["0.0.0.0/0"]

  prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront_global.id]
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
    tomap({ "Name" : "panelapp_elb_sec" })
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
  certificate_arn   = data.terraform_remote_state.infra.outputs.regional_cert

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.panelapp_app_web.arn
  }
}

# Only allow CloudFront requests with a specific header
# Create secret value in AWS SSM Parameter Store
# aws ssm put-parameter --name '/panelapp/<env_name>/elb/cf_req_header_value' --type "SecureString" --value '<secret value>'
data "aws_ssm_parameter" "cf_req_header_value" {
  count = var.create_cloudfront ? 1 : 0
  name  = "/${var.stack}/${var.env_name}/elb/cf_req_header_value"
}

resource "aws_wafv2_web_acl" "waf_acl_cf_req_header" {
  name        = "waf_acl_cf_req_header"
  scope       = "REGIONAL"
  description = "WAF ACL to allow only CloudFront requests with a specific header"

  default_action {
    allow {}
  }

  visibility_config {
    sampled_requests_enabled   = true
    cloudwatch_metrics_enabled = true
    metric_name                = "waf-metric"
  }

  rule {
    name     = "AllowCloudFrontRequestsWithHeader"
    priority = 1
    action {
      block {}
    }

    statement {
      not_statement {
        statement {
          byte_match_statement {
            search_string = data.aws_ssm_parameter.cf_req_header_value[0].value
            field_to_match {
              single_header {
                name = var.waf_acl_cf_req_header_name
              }
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
            positional_constraint = "EXACTLY"
          }
        }
      }
    }

    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowCloudFrontRequestsWithHeader"
    }
  }
}

# Associate the WAF ACL with the ALB which is only accessible via CloudFront for requests with a specific header
resource "aws_wafv2_web_acl_association" "waf_acl_cf_req_header_aws_lb" {
  resource_arn = aws_lb.panelapp.arn
  web_acl_arn  = aws_wafv2_web_acl.waf_acl_cf_req_header.arn
}
