#### Notes
* Aurora cluster can be created from scratch with a database name, username and password or from a snapshot
* Currently, Terraform does not support Aurora snapshots datasource, so snapshot is hardcoded in the module (this is to be fixed as soon as this is supported)
* Database password is taken from SSM Parameter Store, it needs to be created beforehand, currently secrets are outside of automation
```
aws --profile retail-dc2 ssm put-parameter --name '/demo/secret/db_root_pass' --type "SecureString" --key-id alias/dc2-site --value 'password'
aws --profile retail-dc2 ssm get-parameter --name '/demo/secret/db_root_pass' --with-decryption | jq -r .Parameter.Value
```
* Aurora parameters
https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/AuroraMySQL.Reference.html

* Database password is stored in a clear text in terraform s3 remote state

#### Variables
* cluster_size - int, anything higher than 1 creates MultiAZ deployment, where read replicas are used to for promotion to master when needed.

* create_reporting_db - true/false, creates additional reporting database with lower priority in fail-over

* mon_interval - int, manage Enhanced Monitoring

* enable_monintoring - true/false, creates alerts

* skip_final_snapshot - default is false, set to true in a scenario when database is frequently destroyed and created from a snapshot


#### Example usage:
```
module "aurora" {
  source = "../modules/dc2/aurora"

  stage        = "${var.stage}"
  default_tags = "${var.default_tags}"
  vpc_id       = "${data.terraform_remote_state.network-state.vpc_id}"
  subnets      = "${data.terraform_remote_state.network-state.private_subnets}"
  private_zone = "${data.terraform_remote_state.network-state.dns_private_zone}"

  skip_final_snapshot = true
  enable_monitoring   = false
  mon_interval        = false
  sns_topic           = "${aws_sns_topic.monit.arn}"

  database = "dc2"
  username = "root"

  restore_from_snapshot = true
  create_reporting_db   = false
  rds_snapshot          = "aurora-rnd"

  cluster_size   = 1
  instance_class = "db.r3.xlarge"
}
```
