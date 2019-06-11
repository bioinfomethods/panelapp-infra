data "template_file" "panelapp_web" {
  template = "${file("panelapp-web.tpl")}"

  vars = {
    database_url           = "${data.aws_ssm_parameter.db_host.value}"
    aurora_writer_endpoint = "${module.aurora.writer_endpoint}"
    aws_region             = "${var.region}"
    cdn_domain_name        = "${var.cdn_alis}"
    default_email          = "${var.default_email}"
    panelapp_email         = "${var.panelapp_email}"
    email_host             = "${var.smtp_server}"
    email_user             = "${aws_iam_access_key.ses.id}"
    email_password         = "${aws_iam_access_key.ses.ses_smtp_password}"
  }
}

data "template_file" "panelapp_worker" {
  template = "${file("panelapp-worker.tpl")}"

  vars = {
    database_url           = "${data.aws_ssm_parameter.db_host.value}"
    aurora_writer_endpoint = "${module.aurora.writer_endpoint}"
    aws_region             = "${var.region}"
    cdn_domain_name        = "${var.cdn_alis}"
    default_email          = "${var.default_email}"
    panelapp_email         = "${var.panelapp_email}"
    email_host             = "${var.smtp_server}"
    email_user             = "${aws_iam_access_key.ses.id}"
    email_password         = "${aws_iam_access_key.ses.ses_smtp_password}"
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

data "template_file" "panelapp_loaddata" {
  template = "${file("loaddata.tpl")}"

  vars = {
    database_url           = "${data.aws_ssm_parameter.db_host.value}"
    aurora_writer_endpoint = "${module.aurora.writer_endpoint}"
    aws_region             = "${var.region}"
    cdn_domain_name        = "${var.cdn_alis}"
  }
}

data "template_file" "panelapp_createsuperuser" {
  template = "${file("createsuperuser.tpl")}"

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

data "aws_ip_ranges" "amazon_ireland" {
  regions  = ["eu-west-1"]
  services = ["amazon"]
}
