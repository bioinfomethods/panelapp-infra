resource "aws_security_group" "gitlab_runner_fargate" {
  count       = "${var.create_gitlab_runners ? 1 : 0}"
  name        = "gitlab-runner-fargate"
  description = "default group for gitlab runners"
  vpc_id      = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  tags = "${merge(var.default_tags, map("Name", "gitlab-runners-fargate"))}"
}

resource "aws_security_group_rule" "runner_egress_https" {
  count             = "${var.create_gitlab_runners ? 1 : 0}"
  type              = "egress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.gitlab_runner_fargate.id}"
}

resource "aws_security_group_rule" "runner_egress_meta" {
  count             = "${var.create_gitlab_runners ? 1 : 0}"
  type              = "egress"
  from_port         = "0"
  to_port           = "65535"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.gitlab_runner_fargate.id}"
}
