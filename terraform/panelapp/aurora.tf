module "aurora" {
  source = "../modules/aurora"

  env_name     = "${var.env_name}"
  default_tags = "${var.default_tags}"
  vpc_id       = "${data.terraform_remote_state.infra.vpc_id}"
  subnets      = "${data.terraform_remote_state.infra.private_subnets}"
  private_zone = "${data.terraform_remote_state.infra.dns_private_zone}"

  engine_version        = "${var.engine_version}"
  skip_final_snapshot   = true
  enable_monitoring     = false
  mon_interval          = false
  database              = "panelapp"
  username              = "panelapp"
  restore_from_snapshot = "${var.restore_from_snapshot}"
  rds_snapshot          = "${var.snapshot_identifier}"
  cluster_size          = "${var.create_aurora ? var.cluster_size : 0}"
  instance_class        = "${var.db_instance_class}"
  slow_query_log        = true
  long_query_time       = "2"
  cluster_size          = "${var.aurora_replica}"
  rds_db_kms_key        = "${data.terraform_remote_state.infra.rds_shared_kms_arn}"
  rds_backup_retention_period = "${var.rds_backup_retention_period}"
  family_parameters     = "${var.db_family_parameters}"
  deletion_protection   = "${var.rds_deletion_protection}"
}
