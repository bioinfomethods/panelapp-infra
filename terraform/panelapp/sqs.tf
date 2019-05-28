module "sqs" {
  source = "../modules/sqs"

  default_tags = "${var.default_tags}"
  env_name     = "${var.env_name}"
  sqs_name     = "pannelapp-dev"
}
