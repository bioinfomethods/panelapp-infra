#### Notes
* Aurora cluster can be created from scratch with a database name, username and password or from a snapshot. This file is intended for creating postgres cluster, some variables and version will be different for mysql.

* Database password is taken from SSM Parameter Store, it needs to be created beforehand, currently secrets are outside of automation.

```
aws --profile retail-dc2 ssm put-parameter --name '/demo/secret/db_root_pass' --type "SecureString" --key-id alias/dc2-site --value 'password'
aws --profile retail-dc2 ssm get-parameter --name '/demo/secret/db_root_pass' --with-decryption | jq -r .Parameter.Value
```
* Aurora parameters for postgres
https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Reference.html

* Database password is stored in a clear text in terraform s3 remote state

#### Variables
* cluster_size - int, anything higher than 1 creates MultiAZ deployment, where read replicas are used to for promotion to master when needed.

* instance_class - Check the following link to choose a class
https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html

* create_reporting_db - true/false, creates additional reporting database with lower priority in fail-over. This has to be uncommented in aurora.tf before using it.

* mon_interval - int, manage Enhanced Monitoring 

* enable_monintoring - true/false, creates alerts. This has to be uncommented in alarms.tf before using it.

* skip_final_snapshot - default is false, set to true in a scenario when database is frequently destroyed and created from a snapshot


#### Example usage:

```
module "aurora" {
  source = "../modules/aurora"

  env_name     = "${var.env_name}"
  default_tags = "${var.default_tags}"
  vpc_id       = "${data.terraform_remote_state.infra.vpc_id}"
  subnets      = "${data.terraform_remote_state.infra.private_subnets}"
  private_zone = "${data.terraform_remote_state.infra.dns_private_zone}"

  skip_final_snapshot   = true
  enable_monitoring     = false
  mon_interval          = false
  database              = "panelapp"
  username              = "root"
  restore_from_snapshot = false
  cluster_size          = "${var.create_aurora ? var.cluster_size : 0}"
  instance_class        = "db.r5.large"
  slow_query_log        = true
  long_query_time       = "2"
}

```