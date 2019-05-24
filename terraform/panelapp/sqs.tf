module "sqs" {
  source = "../modules/sqs"

  env_name = "${var.env_name}"
  sqs_name = "pannelapp-dev"
}
