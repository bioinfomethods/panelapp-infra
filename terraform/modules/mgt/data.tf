data "aws_ami" "amazon_linux_2" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user_data.tpl")}"
  vars {
    image_name       = "${var.image_name}"
    image_tag        = "${var.image_tag}"
    database_host    = "${var.database_host}"
    database_port    = "${var.database_port}"
    database_name    = "${var.database_name}"
    database_user    = "${var.database_user}"
    env              = "${var.env_name}"
    db_password      = "lorenzo knows"
    aws_region       = "${var.aws_region}"
    panelapp_statics = "${var.panelapp_statics}"
    panelapp_media   = "${var.panelapp_media}"
    cdn_domain_name  = "${var.cdn_domain_name}"
  }
}
