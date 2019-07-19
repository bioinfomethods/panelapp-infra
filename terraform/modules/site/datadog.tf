resource "aws_iam_role" "datadog_aws_integration" {
  count              = "${var.enable_datadog}"
  name               = "${var.stack}-datadog-integration"
  description        = "Role for Datadog AWS Integration"
  assume_role_policy = "${data.aws_iam_policy_document.datadog_aws_integration_assume_role.json}"
}

resource "aws_iam_policy" "datadog_aws_integration" {
  count  = "${var.enable_datadog}"
  name   = "${var.stack}-datadog-integration"
  policy = "${data.aws_iam_policy_document.datadog.json}"
}

data "aws_iam_policy_document" "datadog_aws_integration_assume_role" {
  count = "${var.enable_datadog}"
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::464622532012:root"]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"

      values = [
        "${var.datadog_aws_integration_external_id}",
      ]
    }
  }
}

data "aws_iam_policy_document" "datadog" {
  count = "${var.enable_datadog}"
  statement {
    sid = "1"

    actions = [
      "autoscaling:Describe*",
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "ec2:Describe*",
      "ecs:Describe*",
      "ecs:List*",
      "elasticloadbalancing:Describe*",
      "logs:Get*",
      "logs:Describe*",
      "logs:FilterLogEvents",
      "logs:TestMetricFilter",
      "logs:PutSubscriptionFilter",
      "logs:DeleteSubscriptionFilter",
      "logs:DescribeSubscriptionFilters",
      "rds:Describe*",
      "rds:List*",
      "ses:Get*",
      "sqs:ListQueues",
      "tag:GetResources",
      "tag:GetTagKeys",
      "tag:GetTagValues",
    ]

    resources = [
      "*",
    ]
  }
}
