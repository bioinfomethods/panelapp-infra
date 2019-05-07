# No support for aurora snapshots yet
#data "aws_db_snapshot" "snapshot" {
#  most_recent            = true
#  snapshot_type          = "${var.rds_snapshot_type}"
#  db_instance_identifier = "${var.rds_snapshot}"
#}

data "aws_ssm_parameter" "root_password" {
  count = "${var.restore_from_snapshot ? 0 : 1}"
  name  = "/${var.stage}/secrets/db_root_pass"
}

resource "aws_db_subnet_group" "aurora" {
  name       = "aurora-subnet-group-${var.stage}"
  subnet_ids = ["${var.subnets}"]
  tags       = "${merge(var.default_tags, map("Name", "aurora-subnet-group-${var.stage}"))}"
}

resource "aws_route53_record" "database_master" {
  zone_id = "${var.private_zone}"
  name    = "db-master"
  type    = "CNAME"
  ttl     = 1
  records = ["${aws_rds_cluster.aurora_cluster.endpoint}"]
}

resource "aws_route53_record" "database_read" {
  zone_id = "${var.private_zone}"
  name    = "db-read"
  type    = "CNAME"
  ttl     = 1
  records = ["${aws_rds_cluster.aurora_cluster.reader_endpoint}"]
}
