resource "aws_security_group" "aurora" {
  name   = "aurora-${var.stage}"
  vpc_id = "${var.vpc_id}"
  tags   = "${merge(var.default_tags, map("Name", "aurora-${var.stage}"))}"
}

resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  self              = true
  security_group_id = "${aws_security_group.aurora.id}"
}

resource "aws_security_group_rule" "inbound_mysql" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  self              = true
  security_group_id = "${aws_security_group.aurora.id}"
}

data "aws_iam_policy_document" "monitoring_rds_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  count              = "${var.mon_interval > 0 ? 1 : 0}"
  name               = "rds-enhanced-monitoring-${var.stage}"
  assume_role_policy = "${data.aws_iam_policy_document.monitoring_rds_assume_role_policy.json}"
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring_policy_attach" {
  count      = "${var.mon_interval > 0 ? 1 : 0}"
  role       = "${aws_iam_role.rds_enhanced_monitoring.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}