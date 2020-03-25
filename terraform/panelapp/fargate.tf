resource "aws_ecs_cluster" "panelapp_cluster" {
  count = "${var.create_panelapp_cluster ? 1 : 0}"
  name  = "panelapp-cluster-${var.env_name}"

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
    security_groups = ["${module.aurora.aurora_security_group}", "${aws_security_group.fargate.id}", "${aws_security_group.panelapp_elb.id}"]
    subnets         = ["${data.terraform_remote_state.infra.private_subnets}"]
  }

  depends_on = ["aws_lb.panelapp", "aws_lb_target_group.panelapp_app_web"]

  # tags = "${merge(
  #   var.default_tags,
  #   map("Name", "panelapp_web")
  # )}"
}

resource "aws_ecs_task_definition" "panelapp_web" {
  family                   = "panelapp-web-${var.stack}-${var.env_name}"
  task_role_arn            = "${aws_iam_role.ecs_task_panelapp.arn}"
  execution_role_arn       = "${aws_iam_role.ecs_task_panelapp.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.task_cpu}"
  memory                   = "${var.task_memory}"
  container_definitions    = "${data.template_file.panelapp_web.rendered}"

  # tags = "${merge(
  #   var.default_tags,
  #   map("Name", "panelapp_web")
  # )}"
}

data "template_file" "panelapp_web" {
  template = "${file("templates/panelapp-web.tpl")}"

  vars = {
    image_name = "${var.panelapp_image_repo}/panelapp-web"
    image_tag  = "${var.image_tag}"

    cpu    = "${var.task_cpu}"
    memory = "${var.task_memory}"

    # Application parameters
    gunicorn_workers       = "${var.gunicorn_workers}"
    gunicorn_timeout       = "${var.application_connection_timeout}"
    panel_app_base_host    = "${var.cdn_alis}"
    admin_url              = "${var.admin_url}"
    log_level              = "${var.log_level}"
    database_host          = "${module.aurora.writer_endpoint}"
    database_port          = "${module.aurora.port}"
    database_name          = "${module.aurora.database_name}"
    database_user          = "${module.aurora.database_user}"
    db_password_secret_arn = "${local.db_password_secret_arn}"
    aws_region             = "${var.region}"
    panelapp_statics       = "${aws_s3_bucket.panelapp_statics.id}"
    panelapp_media         = "${aws_s3_bucket.panelapp_media.id}"
    cdn_domain_name        = "${var.cdn_alis}"
    default_email          = "${var.default_email}"
    panelapp_email         = "${var.panelapp_email}"
    email_host             = "${var.smtp_server}"
    email_user             = "${aws_iam_access_key.ses.id}"
    email_password         = "${aws_iam_access_key.ses.ses_smtp_password}"
    gunicorn_accesslog     = "${var.gunicorn_accesslog}"
    aws_use_cognito                 = "${var.use_cognito ? "true" : "false"}"
    aws_cognito_domain_prefix       = "${coalesce(join("", aws_cognito_user_pool_domain.domain.*.domain),"")}"
    aws_cognito_user_pool_client_id = "${coalesce(join("", aws_cognito_user_pool_client.client.*.id),"")}"
  }
}

resource "aws_cloudwatch_log_group" "panelapp_web" {
  name              = "panelapp-web"
  retention_in_days = "${var.log_retention}"

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
    security_groups = ["${module.aurora.aurora_security_group}", "${aws_security_group.fargate.id}", "${aws_security_group.panelapp_elb.id}"]
    subnets         = ["${data.terraform_remote_state.infra.private_subnets}"]
  }

  # tags = "${merge(
  #   var.default_tags,
  #   map("Name", "panelapp_worker")
  # )}"
}

resource "aws_ecs_task_definition" "panelapp_worker" {
  family                   = "panelapp-worker-${var.stack}-${var.env_name}"
  task_role_arn            = "${aws_iam_role.ecs_task_panelapp.arn}"
  execution_role_arn       = "${aws_iam_role.ecs_task_panelapp.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.worker_task_cpu}"
  memory                   = "${var.worker_task_memory}"
  container_definitions    = "${data.template_file.panelapp_worker.rendered}"

  # tags = "${merge(
  #   var.default_tags,
  #   map("Name", "panelapp_worker")
  # )}"
}

data "template_file" "panelapp_worker" {
  template = "${file("templates/panelapp-worker.tpl")}"

  vars = {
    image_name = "${var.panelapp_image_repo}/panelapp-worker"
    image_tag  = "${var.image_tag}"

    gunicorn_workers       = "${var.gunicorn_workers}"
    gunicorn_timeout       = "${var.application_connection_timeout}"
    panel_app_base_host    = "${var.cdn_alis}"
    cpu                    = "${var.worker_task_cpu}"
    memory                 = "${var.worker_task_memory}"
    admin_url              = "${var.admin_url}"
    log_level              = "${var.log_level}"
    database_host          = "${module.aurora.writer_endpoint}"
    database_port          = "${module.aurora.port}"
    database_name          = "${module.aurora.database_name}"
    database_user          = "${module.aurora.database_user}"
    db_password_secret_arn = "${local.db_password_secret_arn}"
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
  retention_in_days = "${var.log_retention}"

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_worker")
  )}"
}

######################################
## Tasks to run on every deployments
######################################

# All independent taks use the same template

## Migrate

resource "aws_ecs_task_definition" "panelapp_migrate" {
  family                   = "panelapp-migrate-${var.stack}-${var.env_name}"
  task_role_arn            = "${aws_iam_role.ecs_task_panelapp.arn}"
  execution_role_arn       = "${aws_iam_role.ecs_task_panelapp.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.task_cpu}"
  memory                   = "${var.task_memory}"
  container_definitions    = "${data.template_file.panelapp_migrate.rendered}"

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_migrate")
  )}"
}

data "template_file" "panelapp_migrate" {
  template = "${file("templates/sh-task.tpl")}"

  vars = {
    container_name = "panelapp-migrate"

    image_name = "${var.panelapp_image_repo}/panelapp-web"
    image_tag  = "${var.image_tag}"

    command = "python manage.py migrate"

    cpu    = "${var.task_cpu}"
    memory = "${var.task_memory}"

    log_group         = "panelapp-migrate"
    log_stream_prefix = "panelapp-migrate"

    # Application parameters
    gunicorn_workers       = "${var.gunicorn_workers}"
    gunicorn_timeout       = "${var.application_connection_timeout}"
    panel_app_base_host    = "${var.cdn_alis}"
    admin_url              = "${var.admin_url}"
    log_level              = "${var.log_level}"
    database_host          = "${module.aurora.writer_endpoint}"
    database_port          = "${module.aurora.port}"
    database_name          = "${module.aurora.database_name}"
    database_user          = "${module.aurora.database_user}"
    db_password_secret_arn = "${local.db_password_secret_arn}"
    aws_region             = "${var.region}"
    panelapp_statics       = "${aws_s3_bucket.panelapp_statics.id}"
    panelapp_media         = "${aws_s3_bucket.panelapp_media.id}"
    cdn_domain_name        = "${var.cdn_alis}"
    default_email          = "${var.default_email}"
    panelapp_email         = "${var.panelapp_email}"
    email_host             = "${var.smtp_server}"
    email_user             = "${aws_iam_access_key.ses.id}"

    email_password = "${aws_iam_access_key.ses.ses_smtp_password}"
  }
}

resource "aws_cloudwatch_log_group" "panelapp_migrate" {
  name              = "panelapp-migrate"
  retention_in_days = "${var.log_retention}"

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_migrate")
  )}"
}

## CollectStatic

resource "aws_ecs_task_definition" "panelapp_collectstatic" {
  family                   = "panelapp-collectstatic-${var.stack}-${var.env_name}"
  task_role_arn            = "${aws_iam_role.ecs_task_panelapp.arn}"
  execution_role_arn       = "${aws_iam_role.ecs_task_panelapp.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.task_cpu}"
  memory                   = "${var.task_memory}"
  container_definitions    = "${data.template_file.panelapp_collectstatic.rendered}"

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_collectstatic")
  )}"
}

data "template_file" "panelapp_collectstatic" {
  template = "${file("templates/sh-task.tpl")}"

  vars = {
    container_name = "panelapp-collectstatic"

    image_name = "${var.panelapp_image_repo}/panelapp-web"
    image_tag  = "${var.image_tag}"

    command = "python manage.py collectstatic --noinput"

    cpu    = "${var.task_cpu}"
    memory = "${var.task_memory}"

    log_group         = "panelapp-collectstatic"
    log_stream_prefix = "panelapp-collectstatic"

    # Application parameters
    gunicorn_workers       = "${var.gunicorn_workers}"
    gunicorn_timeout       = "${var.application_connection_timeout}"
    panel_app_base_host    = "${var.cdn_alis}"
    admin_url              = "${var.admin_url}"
    log_level              = "${var.log_level}"
    database_host          = "${module.aurora.writer_endpoint}"
    database_port          = "${module.aurora.port}"
    database_name          = "${module.aurora.database_name}"
    database_user          = "${module.aurora.database_user}"
    db_password_secret_arn = "${local.db_password_secret_arn}"
    aws_region             = "${var.region}"
    panelapp_statics       = "${aws_s3_bucket.panelapp_statics.id}"
    panelapp_media         = "${aws_s3_bucket.panelapp_media.id}"
    cdn_domain_name        = "${var.cdn_alis}"
    default_email          = "${var.default_email}"
    panelapp_email         = "${var.panelapp_email}"
    email_host             = "${var.smtp_server}"
    email_user             = "${aws_iam_access_key.ses.id}"

    email_password = "${aws_iam_access_key.ses.ses_smtp_password}"
  }
}

resource "aws_cloudwatch_log_group" "panelapp-collectstatic" {
  name              = "panelapp-collectstatic"
  retention_in_days = "${var.log_retention}"

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_collectstatic")
  )}"
}

#######################
## Other one-off tasks
#######################

resource "aws_cloudwatch_log_group" "panelapp-oneoff" {
  name              = "panelapp-oneoff"
  retention_in_days = "${var.log_retention}"

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_oneoff")
  )}"
}

resource "aws_ecs_task_definition" "panelapp_loaddata" {
  family                   = "panelapp-loaddata-${var.stack}-${var.env_name}"
  task_role_arn            = "${aws_iam_role.ecs_task_panelapp.arn}"
  execution_role_arn       = "${aws_iam_role.ecs_task_panelapp.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.task_cpu}"
  memory                   = "${var.task_memory}"
  container_definitions    = "${data.template_file.panelapp_loaddata.rendered}"
}

data "template_file" "panelapp_loaddata" {
  template = "${file("templates/sh-task.tpl")}"

  vars = {
    container_name = "panelapp-loaddata"

    image_name = "${var.panelapp_image_repo}/panelapp-web"
    image_tag  = "${var.image_tag}"

    command = "python -c \\\"import boto3,botocore;boto3.resource('s3').Bucket('${aws_s3_bucket.panelapp_scripts.id}').download_file('genes.json.gz', '/var/tmp/genes.json.gz')\\\" ; python manage.py loaddata --verbosity 3 /var/tmp/genes.json"

    cpu    = "${var.task_cpu}"
    memory = "${var.task_memory}"

    log_group         = "panelapp-oneoff"
    log_stream_prefix = "panelapp-oneoff"

    # Application parameters
    gunicorn_workers       = "${var.gunicorn_workers}"
    gunicorn_timeout       = "${var.application_connection_timeout}"
    panel_app_base_host    = "${var.cdn_alis}"
    admin_url              = "${var.admin_url}"
    log_level              = "${var.log_level}"
    database_host          = "${module.aurora.writer_endpoint}"
    database_port          = "${module.aurora.port}"
    database_name          = "${module.aurora.database_name}"
    database_user          = "${module.aurora.database_user}"
    db_password_secret_arn = "${local.db_password_secret_arn}"
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

resource "aws_ecs_task_definition" "panelapp_createsuperuser" {
  family                   = "panelapp-createsuperuser-${var.stack}-${var.env_name}"
  task_role_arn            = "${aws_iam_role.ecs_task_panelapp.arn}"
  execution_role_arn       = "${aws_iam_role.ecs_task_panelapp.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.task_cpu}"
  memory                   = "${var.task_memory}"
  container_definitions    = "${data.template_file.panelapp_createsuperuser.rendered}"
}

data "template_file" "panelapp_createsuperuser" {
  template = "${file("templates/sh-task.tpl")}"

  vars = {
    container_name = "panelapp-createsuperuser"

    image_name = "${var.panelapp_image_repo}/panelapp-web"
    image_tag  = "${var.image_tag}"

    command = "echo \\\"from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', '${var.admin_email}', 'secret')\\\" | python manage.py shell"
    cpu     = "${var.task_cpu}"
    memory  = "${var.task_memory}"

    log_group         = "panelapp-oneoff"
    log_stream_prefix = "panelapp-oneoff"

    # Application parameters
    gunicorn_workers       = "${var.gunicorn_workers}"
    gunicorn_timeout       = "${var.application_connection_timeout}"
    panel_app_base_host    = "${var.cdn_alis}"
    admin_url              = "${var.admin_url}"
    log_level              = "${var.log_level}"
    database_host          = "${module.aurora.writer_endpoint}"
    database_port          = "${module.aurora.port}"
    database_name          = "${module.aurora.database_name}"
    database_user          = "${module.aurora.database_user}"
    db_password_secret_arn = "${local.db_password_secret_arn}"
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
