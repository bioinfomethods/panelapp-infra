resource "aws_ecs_cluster" "gitlab_runners" {
  count = "${var.create_gitlab_runners ? 1 : 0}"
  name  = "gitlab-runners"
}

resource "aws_cloudwatch_log_group" "gitlab_runners" {
  count             = "${var.create_gitlab_runners ? 1 : 0}"
  name              = "gitlab-runners"
  retention_in_days = 3
}

data "template_file" "gitlab_runner" {
  template = "${file("${path.module}/gitlab_runner.tpl")}"

  vars {
    app_cpu    = "${var.app_cpu}"
    app_image  = "${var.app_image}"
    app_memory = "${var.app_memory}"
    token_from = "${var.token_from}"
    app_region = "${var.app_region}"
    additional_runner_tag = "${var.additional_runner_tag}"

  }
}
