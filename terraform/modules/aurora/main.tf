# No support for aurora snapshots yet
#data "aws_db_snapshot" "snapshot" {
#  most_recent            = true
#  snapshot_type          = "${var.rds_snapshot_type}"
#  db_instance_identifier = "${var.rds_snapshot}"
#}

data "aws_ssm_parameter" "root_password" {
  count = "${var.restore_from_snapshot ? 0 : 1}"
  name  = "/${var.stack}/${var.env_name}/database/master_password"
}

# resource "aws_ssm_parameter" "secret" {
#   name        = "/${var.stack}/${var.env_name}/database/master_password"
#   description = "DB password"
#   type        = "SecureString"
#   value       = "${var.password}"
# }

resource "aws_db_subnet_group" "aurora" {
  name       = "aurora-subnet-group-${var.env_name}"
  subnet_ids = ["${var.subnets}"]
  tags       = "${merge(var.default_tags, map("Name", "aurora-subnet-group-${var.env_name}"))}"
}

# resource "aws_route53_record" "database_master" {
#   zone_id = "${var.private_zone}"
#   name    = "db-master"
#   type    = "CNAME"
#   ttl     = 1
#   records = ["${aws_rds_cluster.aurora_cluster.endpoint}"]
# }


# resource "aws_route53_record" "database_read" {
#   zone_id = "${var.private_zone}"
#   name    = "db-read"
#   type    = "CNAME"
#   ttl     = 1
#   records = ["${aws_rds_cluster.aurora_cluster.reader_endpoint}"]
# }

