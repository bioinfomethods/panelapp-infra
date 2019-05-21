resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier = "aurora-${var.env_name}"

  engine                    = "aurora-postgresql"
  engine_version            = "9.6.9"
  final_snapshot_identifier = "aurora-${var.env_name}"
  skip_final_snapshot       = "${var.skip_final_snapshot}"
  storage_encrypted         = true
  db_subnet_group_name      = "${aws_db_subnet_group.aurora.name}"

  vpc_security_group_ids = [
    "${aws_security_group.aurora.id}",
    "${var.additional_security_groups}",
  ]

  database_name   = "${var.database}"
  master_username = "${var.username}"

  //master_password = "${var.password}"

  master_password     = "${join("",data.aws_ssm_parameter.root_password.*.value)}"
  snapshot_identifier = "${var.restore_from_snapshot ? var.rds_snapshot : ""}"
  tags = "${merge(
    var.default_tags,
    map("Name", "cluster-${var.env_name}")
  )}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster_instance" "aurora_cluster_instance" {
  count = "${var.cluster_size}"

  engine                  = "aurora-postgresql"
  engine_version          = "9.6.9"
  identifier              = "${var.env_name}-db${count.index + 1}"
  cluster_identifier      = "${aws_rds_cluster.aurora_cluster.id}"
  instance_class          = "${var.instance_class}"
  db_subnet_group_name    = "${aws_db_subnet_group.aurora.name}"
  monitoring_interval     = "${var.mon_interval}"
  monitoring_role_arn     = "${join("", aws_iam_role.rds_enhanced_monitoring.*.arn)}"
  publicly_accessible     = false
  promotion_tier          = "0"
  db_parameter_group_name = "${aws_db_parameter_group.custom_instnace_parameters.id}"

  tags = "${merge(
    var.default_tags,
    map("Name", "${var.env_name}-db${count.index + 1}")
  )}"

  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_rds_cluster_instance" "aurora_cluster_reporting_instance" {
#   count = "${var.create_reporting_db}"


#   identifier           = "${var.env_name}-reporting-db${count.index + 1}"
#   cluster_identifier   = "${aws_rds_cluster.aurora_cluster.id}"
#   instance_class       = "${var.instance_class}"
#   db_subnet_group_name = "${aws_db_subnet_group.aurora.name}"
#   monitoring_interval  = "${var.mon_interval}"
#   monitoring_role_arn  = "${join("", aws_iam_role.rds_enhanced_monitoring.*.arn)}"
#   publicly_accessible  = false
#   promotion_tier       = "1"


#   tags = "${merge(
#     var.default_tags,
#     map("Name", "${var.env_name}-reporting-db${count.index + 1}")
#   )}"


#   lifecycle {
#     create_before_destroy = true
#   }
# }

