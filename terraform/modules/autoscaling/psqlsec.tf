resource "aws_security_group_rule" "postgres_client_egress_http" {
  # count             = "${var.create_postgres_client ? 1 : 0}"
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.postgres_client.id}"
  description       = "http egres for software repos"
}

resource "aws_security_group_rule" "postgres_client_egress_https" {
  # count             = "${var.create_postgres_client ? 1 : 0}"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.postgres_client.id}"
  description       = "https egres for aws apis"
}

resource "aws_security_group" "postgres_client" {
  # count       = "${var.create_postgres_client ? 1 : 0}"
  name        = "postgres-client"
  description = "default group for postgres_client"
  vpc_id      = "${data.terraform_remote_state.infra.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  # tags = "${merge(var.default_tags, map("Name", "postgres-client-${var.stack}-${var.env_name}"))}"
}