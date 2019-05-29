data "terraform_remote_state" "infra" {
  backend = "s3"

  config {
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "infra/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.tpl")}"
}
