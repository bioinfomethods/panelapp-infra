# FIXME Either we delete this or use the `enable_monitoring` switch to turn it on and off

# resource "aws_cloudwatch_metric_alarm" "alarm_rds_database_connections_writer" {
#   count               = "${var.enable_monitoring ? 1 : 0}"
#   alarm_name          = "${aws_rds_cluster.aurora_cluster.id}-writer-database-connections"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "1"
#   metric_name         = "DatabaseConnections"
#   namespace           = "AWS/RDS"
#   period              = "60"
#   statistic           = "Sum"
#   threshold           = "${var.db_max_conns}"
#   alarm_description   = "RDS Maximum connection Alarm for ${aws_rds_cluster.aurora_cluster.id} writer"
#   alarm_actions       = ["${var.sns_topic}"]
#   ok_actions          = ["${var.sns_topic}"]
#   dimensions {
#     DBClusterIdentifier = "${aws_rds_cluster.aurora_cluster.id}"
#     Role                = "WRITER"
#   }
# }
# resource "aws_cloudwatch_metric_alarm" "alarm_rds_database_connections_reader" {
#   count               = "${var.enable_monitoring && var.cluster_size > 0 ? 1 : 0}"
#   alarm_name          = "${aws_rds_cluster.aurora_cluster.id}-reader-database-connections"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "1"
#   metric_name         = "DatabaseConnections"
#   namespace           = "AWS/RDS"
#   period              = "60"
#   statistic           = "Maximum"
#   threshold           = "${var.db_max_conns}"
#   alarm_description   = "RDS Maximum connection Alarm for ${aws_rds_cluster.aurora_cluster.id} reader(s)"
#   alarm_actions       = ["${var.sns_topic}"]
#   ok_actions          = ["${var.sns_topic}"]
#   dimensions {
#     DBClusterIdentifier = "${aws_rds_cluster.aurora_cluster.id}"
#     Role                = "READER"
#   }
# }
# resource "aws_cloudwatch_metric_alarm" "alarm_rds_CPU_writer" {
#   count               = "${var.enable_monitoring ? 1 : 0}"
#   alarm_name          = "${aws_rds_cluster.aurora_cluster.id}-writer-CPU"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/RDS"
#   period              = "60"
#   statistic           = "Maximum"
#   threshold           = "${var.db_max_cpu}"
#   alarm_description   = "RDS CPU Alarm for ${aws_rds_cluster.aurora_cluster.id} writer"
#   alarm_actions       = ["${var.sns_topic}"]
#   ok_actions          = ["${var.sns_topic}"]
#   dimensions {
#     DBClusterIdentifier = "${aws_rds_cluster.aurora_cluster.id}"
#     Role                = "WRITER"
#   }
# }
# resource "aws_cloudwatch_metric_alarm" "alarm_rds_CPU_reader" {
#   count               = "${var.enable_monitoring && var.cluster_size > 0 ? 1 : 0}"
#   alarm_name          = "${aws_rds_cluster.aurora_cluster.id}-reader-CPU"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/RDS"
#   period              = "60"
#   statistic           = "Maximum"
#   threshold           = "${var.db_max_cpu}"
#   alarm_description   = "RDS CPU Alarm for ${aws_rds_cluster.aurora_cluster.id} reader(s)"
#   alarm_actions       = ["${var.sns_topic}"]
#   ok_actions          = ["${var.sns_topic}"]
#   dimensions {
#     DBClusterIdentifier = "${aws_rds_cluster.aurora_cluster.id}"
#     Role                = "READER"
#   }
# }
# resource "aws_cloudwatch_metric_alarm" "alarm_rds_replica_lag" {
#   count               = "${var.enable_monitoring && var.cluster_size > 0 ? 1 : 0}"
#   alarm_name          = "${aws_rds_cluster.aurora_cluster.id}-reader-replica-lag"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "5"
#   metric_name         = "AuroraReplicaLag"
#   namespace           = "AWS/RDS"
#   period              = "60"
#   statistic           = "Maximum"
#   threshold           = "${var.max_replica_lag}"
#   alarm_description   = "RDS CPU Alarm for ${aws_rds_cluster.aurora_cluster.id}"
#   alarm_actions       = ["${var.sns_topic}"]
#   ok_actions          = ["${var.sns_topic}"]
#   dimensions {
#     DBClusterIdentifier = "${aws_rds_cluster.aurora_cluster.id}"
#     Role                = "READER"
#   }
# }
