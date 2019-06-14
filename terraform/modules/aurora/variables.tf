variable "stack" {
  description = "Stack name"
  default     = "panelapp"
}

variable "env_name" {}

variable "default_tags" {
  type    = "map"
  default = {}
}

variable "rds_snapshot" {
  default = ""
}

variable "rds_snapshot_type" {
  default = "automated"
}

variable "subnets" {
  type = "list"
}

variable "instance_class" {}
variable "vpc_id" {}

variable "cluster_size" {
  default = 1
}

variable "create_reporting_db" {
  default = false
}

variable "create_aurora" {
  default = true
}

variable "auto_minor_version_upgrade" {
  default = false
}

variable "skip_final_snapshot" {
  default = false
}

variable "additional_security_groups" {
  default = []
}

variable "private_zone" {}

variable "database" {
  default = ""
}

variable "mon_interval" {
  default = 0
}

variable "username" {
  default = ""
}

variable "restore_from_snapshot" {
  default = false
}

variable "sns_topic" {
  default = ""
}

variable "enable_monitoring" {
  default = false
}

variable "engine_version" {
  description = "postgres version"
}

variable "db_max_conns" {
  default = "500"
}

variable "db_max_cpu" {
  default = "80"
}

variable "max_replica_lag" {
  default     = "2000"
  description = "Maximum Aurora replica lag in milliseconds"
}

variable "slow_query_log" {
  default = false
}

variable "long_query_time" {
  default = "2"
}

variable "innodb_flush_log_at_trx_commit" {
  default = "1"
}

variable "query_cache_type" {
  default = "1"
}

variable "query_cache_size" {
  default = "{DBInstanceClassMemory/24}"
}

variable "backtrack_window" {
  default = "0"
}
