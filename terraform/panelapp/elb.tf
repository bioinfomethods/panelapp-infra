resource "aws_lb" "test" {
  name               = "panelapp-elb"
  internal           = true
  load_balancer_type = "application"

  subnets = ["${data.terraform_remote_state.infra.private_subnets}"]

  # subnet_mapping {
  #   subnets = "${data.terraform_remote_state.infra.private_subnets}"
  # }

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_elb")
  )}"
}
