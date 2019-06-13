resource "aws_ecs_cluster" "panelapp_cluster" {
  name = "panelapp-cluster-${var.env_name}"

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_cluster")
  )}"
}


########################
## Application cluster
########################

## Web

resource "aws_ecs_service" "panelapp_web" {
  name            = "panelapp-web-${var.stack}-${var.env_name}"
  cluster         = "${aws_ecs_cluster.panelapp_cluster.id}"
  task_definition = "${aws_ecs_task_definition.panelapp_web.arn}"
  desired_count   = "${var.panelapp_replica}"
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = "${aws_lb_target_group.panelapp_app_web.arn}"
    container_name   = "panelapp-web"
    container_port   = 8080
  }

  network_configuration {
    security_groups = ["${module.aurora.aurora_security_group}", "${aws_security_group.fargte.id}"]
    subnets         = ["${data.terraform_remote_state.infra.private_subnets}"]
  }

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_web")
  )}"
}

resource "aws_ecs_task_definition" "panelapp_web" {
  family                   = "panelapp-web-${var.stack}-${var.env_name}"
  task_role_arn            = "${aws_iam_role.ecs_task_panelapp.arn}"
  execution_role_arn       = "${aws_iam_role.ecs_task_panelapp.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512 # FIXME Externalise as configuration (with default)
  memory                   = 1024 # FIXME Externalise...
  container_definitions    = "${data.template_file.panelapp_web.rendered}"
  # FIXME "image", "log-level" (in the template) must be externalised
  # FIXME do not pass the DB URL directly but let fargate fetching as secrets (pass db URL as separate elements [IP-3610]
  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_web")
  )}"
}

data "template_file" "panelapp_web" {
  template = "${file("templates/panelapp-web.tpl")}"

  vars = {
    database_host          = "${module.aurora.writer_endpoint}",
    database_port          = "${module.aurora.port}",
    database_name          = "${module.aurora.database_name}",
    database_user          = "${module.aurora.database_user}",
    db_password_secret_arn = "${local.db_password_secret_arn}",
    aws_region             = "${var.region}"
    panelapp_statics       = "${aws_s3_bucket.panelapp_statics.id}"
    panelapp_media         = "${aws_s3_bucket.panelapp_media.id}"
    cdn_domain_name        = "${var.cdn_alis}"
    default_email          = "${var.default_email}"
    panelapp_email         = "${var.panelapp_email}"
    email_host             = "${var.smtp_server}"
    email_user             = "${aws_iam_access_key.ses.id}"
    # FIXME Cannot we pass the SMTP password as a container secret through parameter store?
    email_password         = "${aws_iam_access_key.ses.ses_smtp_password}"
  }
}

resource "aws_cloudwatch_log_group" "panelapp_web" {
  name              = "panelapp-web"
  retention_in_days = 14

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_web")
  )}"
}



## Worker

resource "aws_ecs_service" "panelapp_worker" {
  name            = "panelapp-worker-${var.stack}-${var.env_name}"
  cluster         = "${aws_ecs_cluster.panelapp_cluster.id}"
  task_definition = "${aws_ecs_task_definition.panelapp_worker.arn}"
  desired_count   = "${var.panelapp_replica}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${module.aurora.aurora_security_group}", "${aws_security_group.fargte.id}"]
    subnets         = ["${data.terraform_remote_state.infra.private_subnets}"]
  }

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_worker")
  )}"
}

resource "aws_ecs_task_definition" "panelapp_worker" {
  family                   = "panelapp-worker-${var.stack}-${var.env_name}"
  task_role_arn            = "${aws_iam_role.ecs_task_panelapp.arn}"
  execution_role_arn       = "${aws_iam_role.ecs_task_panelapp.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512 # FIXME Externalise...
  memory                   = 1024 # FIXME Externalise...
  container_definitions    = "${data.template_file.panelapp_worker.rendered}" # FIXME externalise "image"
  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_worker")
  )}"
}

data "template_file" "panelapp_worker" {
  template = "${file("templates/panelapp-worker.tpl")}"

  vars = {
    database_host          = "${module.aurora.writer_endpoint}",
    database_port          = "${module.aurora.port}",
    database_name          = "${module.aurora.database_name}",
    database_user          = "${module.aurora.database_user}",
    db_password_secret_arn = "${local.db_password_secret_arn}",
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

resource "aws_cloudwatch_log_group" "panelapp_worker" {
  name              = "panelapp-worker"
  retention_in_days = 14

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_worker")
  )}"
}




######################################
## Tasks to run on every deployments
######################################

## Migrate

resource "aws_ecs_task_definition" "panelapp_migrate" {
  family                   = "panelapp-migrate-${var.stack}-${var.env_name}"
  task_role_arn            = "${aws_iam_role.ecs_task_panelapp.arn}"
  execution_role_arn       = "${aws_iam_role.ecs_task_panelapp.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512 # FIXME Externalise...
  memory                   = 1024 # FIXME Externalise...
  container_definitions    = "${data.template_file.panelapp_migrate.rendered}" # FIXME externalise "image"
  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_migrate")
  )}"
}

data "template_file" "panelapp_migrate" {
  template = "${file("templates/migrate.tpl")}"

  vars = {
    database_host          = "${module.aurora.writer_endpoint}",
    database_port          = "${module.aurora.port}",
    database_name          = "${module.aurora.database_name}",
    database_user          = "${module.aurora.database_user}",
    db_password_secret_arn = "${local.db_password_secret_arn}",
    aws_region             = "${var.region}"
    panelapp_statics       = "${aws_s3_bucket.panelapp_statics.id}"
    panelapp_media         = "${aws_s3_bucket.panelapp_media.id}"
    cdn_domain_name        = "${var.cdn_alis}"
  }
}

resource "aws_cloudwatch_log_group" "panelapp_migrate" {
  name              = "panelapp-migrate"
  retention_in_days = 14 # FIXME Make this configurable

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_migrate")
  )}"
}


## CollectStatic

resource "aws_ecs_task_definition" "panelapp_collectstatic" {
  family                   = "panelapp-collectstatic-${var.stack}-${var.env_name}" # FIXME externalise "image"
  task_role_arn            = "${aws_iam_role.ecs_task_panelapp.arn}"
  execution_role_arn       = "${aws_iam_role.ecs_task_panelapp.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512 # FIXME Externalise...
  memory                   = 1024 # FIXME Externalise...
  container_definitions    = "${data.template_file.panelapp_collectstatic.rendered}"
  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_collectstatic")
  )}"
}

data "template_file" "panelapp_collectstatic" {
  template = "${file("templates/collectstatic.tpl")}"

  vars = {
    database_host          = "${module.aurora.writer_endpoint}",
    database_port          = "${module.aurora.port}",
    database_name          = "${module.aurora.database_name}",
    database_user          = "${module.aurora.database_user}",
    db_password_secret_arn = "${local.db_password_secret_arn}",
    aws_region             = "${var.region}"
    panelapp_statics       = "${aws_s3_bucket.panelapp_statics.id}"
    panelapp_media         = "${aws_s3_bucket.panelapp_media.id}"
    cdn_domain_name        = "${var.cdn_alis}"
  }
}

resource "aws_cloudwatch_log_group" "panelapp-collectstatic" {
  name              = "panelapp-collectstatic"
  retention_in_days = 14 # FIXME Make this configurable

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_collectstatic")
  )}"
}


#######################
## Other one-off tasks
#######################

# FIXME Move one-off tasks out of terraform (verify if possible to override the entrypoint when running the task)
# FIXME use a single log group for all one-off tasks

resource "aws_ecs_task_definition" "panelapp_loaddata" {
  family                   = "panelapp-loaddata-${var.stack}-${var.env_name}"
  task_role_arn            = "${aws_iam_role.ecs_task_panelapp.arn}"
  execution_role_arn       = "${aws_iam_role.ecs_task_panelapp.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512 # FIXME Externalise...
  memory                   = 1024 # FIXME Externalise...
  container_definitions    = "${data.template_file.panelapp_loaddata.rendered}" # FIXME externalise "image"
  # FIXME add tags
}


data "template_file" "panelapp_loaddata" {
  template = "${file("templates/loaddata.tpl")}"

  vars = {
    database_host          = "${module.aurora.writer_endpoint}",
    database_port          = "${module.aurora.port}",
    database_name          = "${module.aurora.database_name}",
    database_user          = "${module.aurora.database_user}",
    db_password_secret_arn = "${local.db_password_secret_arn}",
    aws_region             = "${var.region}"
    panelapp_statics       = "${aws_s3_bucket.panelapp_statics.id}"
    panelapp_media         = "${aws_s3_bucket.panelapp_media.id}"
    cdn_domain_name        = "${var.cdn_alis}"
  }
}


resource "aws_ecs_task_definition" "panelapp_createsuperuser" {
  family                   = "panelapp-createsuperuser-${var.stack}-${var.env_name}"
  task_role_arn            = "${aws_iam_role.ecs_task_panelapp.arn}"
  execution_role_arn       = "${aws_iam_role.ecs_task_panelapp.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512 # FIXME Externalise...
  memory                   = 1024 # FIXME Externalise...
  container_definitions    = "${data.template_file.panelapp_createsuperuser.rendered}" # FIXME externalise "image"
  # FIXME add tags
}


data "template_file" "panelapp_createsuperuser" {
  template = "${file("templates/createsuperuser.tpl")}"

  vars = {
    database_host          = "${module.aurora.writer_endpoint}",
    database_port          = "${module.aurora.port}",
    database_name          = "${module.aurora.database_name}",
    database_user          = "${module.aurora.database_user}",
    db_password_secret_arn = "${local.db_password_secret_arn}",
    aws_region             = "${var.region}"
    panelapp_statics       = "${aws_s3_bucket.panelapp_statics.id}"
    panelapp_media         = "${aws_s3_bucket.panelapp_media.id}"
    cdn_domain_name        = "${var.cdn_alis}"
    admin_email            = "${var.admin_email}"
  }
}

