# FIXME these should be moved in the files creating the resources using each template

data "template_file" "panelapp_web" {
  template = "${file("panelapp-web.tpl")}"

  vars = {
    database_url           = "${data.aws_ssm_parameter.db_host.value}"
    aurora_writer_endpoint = "${module.aurora.writer_endpoint}"
    aws_region             = "${var.region}"
    panelapp_statics       = "${aws_s3_bucket.panelapp_statics.id}"
    panelapp_media         = "${aws_s3_bucket.panelapp_media.id}"
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
    panelapp_statics       = "${aws_s3_bucket.panelapp_statics.id}"
    panelapp_media         = "${aws_s3_bucket.panelapp_media.id}"
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
    panelapp_statics       = "${aws_s3_bucket.panelapp_statics.id}"
    panelapp_media         = "${aws_s3_bucket.panelapp_media.id}"
    cdn_domain_name        = "${var.cdn_alis}"
  }
}

data "template_file" "panelapp_collectstatic" {
  template = "${file("collectstatic.tpl")}"

  vars = {
    database_url           = "${data.aws_ssm_parameter.db_host.value}"
    aurora_writer_endpoint = "${module.aurora.writer_endpoint}"
    aws_region             = "${var.region}"
    panelapp_statics       = "${aws_s3_bucket.panelapp_statics.id}"
    panelapp_media         = "${aws_s3_bucket.panelapp_media.id}"
    cdn_domain_name        = "${var.cdn_alis}"
  }
}

data "template_file" "panelapp_loaddata" {
  template = "${file("loaddata.tpl")}"

  vars = {
    database_url           = "${data.aws_ssm_parameter.db_host.value}"
    aurora_writer_endpoint = "${module.aurora.writer_endpoint}"
    aws_region             = "${var.region}"
    panelapp_statics       = "${aws_s3_bucket.panelapp_statics.id}"
    panelapp_media         = "${aws_s3_bucket.panelapp_media.id}"
    cdn_domain_name        = "${var.cdn_alis}"
  }
}

data "template_file" "panelapp_createsuperuser" {
  template = "${file("createsuperuser.tpl")}"

  vars = {
    database_url           = "${data.aws_ssm_parameter.db_host.value}"
    aurora_writer_endpoint = "${module.aurora.writer_endpoint}"
    aws_region             = "${var.region}"
    panelapp_statics       = "${aws_s3_bucket.panelapp_statics.id}"
    panelapp_media         = "${aws_s3_bucket.panelapp_media.id}"
    cdn_domain_name        = "${var.cdn_alis}"
    admin_email            = "${var.admin_email}"
  }
}

data "aws_ssm_parameter" "db_host" {
  name = "/${var.stack}/${var.env_name}/database/host"
}

# FIXME These two IP ranges must be generalised. They must be related to the region the stack is deployed to.
#       For SES SMTP we must use a separate variable to define the Region of the SMTP server
data "aws_ip_ranges" "amazon_london" {
  regions  = ["eu-west-2"]
  services = ["amazon"]
}

# FIXME This does not seem to be used
data "aws_ip_ranges" "amazon_ireland" {
  regions  = ["eu-west-1"]
  services = ["amazon"]
}
