resource "aws_cloudwatch_log_group" "panelapp" {
  name              = "panelapp"
  retention_in_days = 14
}
