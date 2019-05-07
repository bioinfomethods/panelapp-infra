output "aurora_security_group" {
  value = "${aws_security_group.aurora.id}"
}

output "writer_endpoint" {
  value = "${aws_rds_cluster.aurora_cluster.endpoint}"
}

output "reader_endpoint" {
  value = "${aws_rds_cluster.aurora_cluster.reader_endpoint}"
}
