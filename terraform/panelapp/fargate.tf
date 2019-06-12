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

resource "aws_ecs_task_definition" "panelapp_web" {
  family                   = "panelapp-web-${var.stack}-${var.env_name}"
  task_role_arn            = "${aws_iam_role.ecs_task_panelapp.arn}"
  execution_role_arn       = "${aws_iam_role.ecs_task_panelapp.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512 # FIXME Externalise as configuration (with default)
  memory                   = 1024 # FIXME Externalise...
  container_definitions    = "${data.template_file.panelapp_web.rendered}" # FIXME "image" (in the template) must be externalised
  # FIXME add tags
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
  # FIXME add tags
}


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

  # FIXME add tags
}

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

  # FIXME add tags
}

resource "aws_cloudwatch_log_group" "panelapp_web" {
  name              = "panelapp-web"
  retention_in_days = 14

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_cluster")
  )}"
}

resource "aws_cloudwatch_log_group" "panelapp_worker" {
  name              = "panelapp-worker"
  retention_in_days = 14

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_cluster")
  )}"
}




######################################
## Tasks to run on every deployments
######################################

resource "aws_ecs_task_definition" "panelapp_migrate" {
  family                   = "panelapp-migrate-${var.stack}-${var.env_name}"
  task_role_arn            = "${aws_iam_role.ecs_task_panelapp.arn}"
  execution_role_arn       = "${aws_iam_role.ecs_task_panelapp.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512 # FIXME Externalise...
  memory                   = 1024 # FIXME Externalise...
  container_definitions    = "${data.template_file.panelapp_migrate.rendered}" # FIXME externalise "image"
  # FIXME add tags
}

resource "aws_ecs_task_definition" "panelapp_collectstatic" {
  family                   = "panelapp-collectstatic-${var.stack}-${var.env_name}" # FIXME externalise "image"
  task_role_arn            = "${aws_iam_role.ecs_task_panelapp.arn}"
  execution_role_arn       = "${aws_iam_role.ecs_task_panelapp.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512 # FIXME Externalise...
  memory                   = 1024 # FIXME Externalise...
  container_definitions    = "${data.template_file.panelapp_collectstatic.rendered}"
  # FIXME add tags
}

resource "aws_cloudwatch_log_group" "panelapp_migrate" {
  name              = "panelapp-migrate"
  retention_in_days = 14

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_cluster")
  )}"
}

resource "aws_cloudwatch_log_group" "panelapp-collectstatic" {
  name              = "panelapp-collectstatic"
  retention_in_days = 14

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_cluster")
  )}"
}


#######################
## Other one-off tasks
#######################

## FIXME Move one-off tasks out of terraform

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

