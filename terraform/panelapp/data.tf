data "template_file" "panelapp_web" {
  template = "${file("panelapp-web.tpl")}"

  vars = {
    database_url           = "${data.aws_ssm_parameter.db_host.value}"
    aurora_writer_endpoint = "${module.aurora.writer_endpoint}"
    aws_region             = "${var.region}"
    cdn_domain_name        = "${var.cdn_alis}"
  }
}

data "template_file" "panelapp_worker" {
  template = "${file("panelapp-worker.tpl")}"

  vars = {
    database_url           = "${data.aws_ssm_parameter.db_host.value}"
    aurora_writer_endpoint = "${module.aurora.writer_endpoint}"
    aws_region             = "${var.region}"
    cdn_domain_name        = "${var.cdn_alis}"
  }
}

data "template_file" "panelapp_migrate" {
  template = "${file("migrate.tpl")}"

  vars = {
    database_url           = "${data.aws_ssm_parameter.db_host.value}"
    aurora_writer_endpoint = "${module.aurora.writer_endpoint}"
    aws_region             = "${var.region}"
    cdn_domain_name        = "${var.cdn_alis}"
  }
}

data "template_file" "panelapp_collectstatic" {
  template = "${file("collectstatic.tpl")}"

  vars = {
    database_url           = "${data.aws_ssm_parameter.db_host.value}"
    aurora_writer_endpoint = "${module.aurora.writer_endpoint}"
    aws_region             = "${var.region}"
    cdn_domain_name        = "${var.cdn_alis}"
  }
}

data "aws_ssm_parameter" "db_host" {
  name = "/${var.stack}/${var.env_name}/database/host"
}

data "aws_ip_ranges" "amazon_london" {
  regions  = ["eu-west-2"]
  services = ["amazon"]
}
