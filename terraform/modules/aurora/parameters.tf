resource "aws_rds_cluster_parameter_group" "custom_cluster_parameters" {
  name        = "custom-cluster-${var.stage}"
  family      = "aurora5.6"
  description = "RDS cluster custom parameters"

  parameter {
    name         = "innodb_flush_log_at_trx_commit"
    value        = "${var.innodb_flush_log_at_trx_commit}"
    apply_method = "immediate"
  }
}

resource "aws_db_parameter_group" "custom_instnace_parameters" {
  name   = "custom-instance-${var.stage}"
  family = "aurora5.6"

  tags = "${merge(
    var.default_tags,
    map("Name", "custom-instance-${var.stage}")
  )}"

  parameter {
    name         = "slow_query_log"
    value        = "${var.slow_query_log}"
    apply_method = "immediate"
  }

  parameter {
    name         = "long_query_time"
    value        = "${var.long_query_time}"
    apply_method = "immediate"
  }

  parameter {
    name         = "query_cache_type"
    value        = "${var.query_cache_type}"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "query_cache_size"
    value        = "${var.query_cache_size}"
    apply_method = "immediate"
  }
}
