resource "aws_security_group_rule" "postgres_client_egress_http" {
  count       = var.create_asg ? 1 : 0
  type        = "egress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.postgres_client.*.id)
  description = "http egress for software repos"
}

resource "aws_security_group_rule" "postgres_client_egress_https" {
  count       = var.create_asg ? 1 : 0
  type        = "egress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.postgres_client.*.id)
  description = "https egress for aws apis"
}

resource "aws_security_group" "postgres_client" {
  count       = var.create_asg ? 1 : 0
  name        = "postgres-client"
  description = "default group for postgres_client"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  #   tags = merge(var.default_tags, tomap({"Name": "postgres-client-${var.stack}-${var.env_name}"}))
}
