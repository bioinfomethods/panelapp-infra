module "aurora" {
  source = "../modules/aurora"

  env_name     = "${var.env_name}"
  default_tags = "${var.default_tags}"
  vpc_id       = "${data.terraform_remote_state.infra.vpc_id}"
  subnets      = "${data.terraform_remote_state.infra.private_subnets}"
  private_zone = "${data.terraform_remote_state.infra.dns_private_zone}"

  engine_version        = "9.6.9"
  skip_final_snapshot   = true
  enable_monitoring     = false
  mon_interval          = false
  database              = "panelapp"
  username              = "panelapp"
  restore_from_snapshot = false
  cluster_size          = "${var.create_aurora ? var.cluster_size : 0}"
  instance_class        = "${var.db_instance_class}"
  slow_query_log        = true
  long_query_time       = "2"
  cluster_size          = "${var.aurora_replica}"
  rds_db_kms_key        = "${data.terraform_remote_state.infra.rds_shared_kms_arn}"
}
