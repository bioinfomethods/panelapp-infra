resource "aws_ecs_cluster" "gitlab_runners" {
  count = var.create_gitlab_runners ? 1 : 0
  name  = "gitlab-runners"
}

resource "aws_cloudwatch_log_group" "gitlab_runners" {
  count             = var.create_gitlab_runners ? 1 : 0
  name              = "gitlab-runners"
  retention_in_days = 3
}
