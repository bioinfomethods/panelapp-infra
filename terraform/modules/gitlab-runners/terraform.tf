resource "aws_ecs_task_definition" "gitlab_runner_tf" {
  count              = var.create_runner_terraform ? 1 : 0
  family             = "gitlab-runner-terraform"
  task_role_arn      = aws_iam_role.ecs_tasks_gitlab_runner_tf[0].arn
  execution_role_arn = aws_iam_role.ecs_tasks_gitlab_runner_tf[0].arn
  network_mode       = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                = var.app_cpu
  memory             = var.app_memory
  container_definitions = templatefile("${path.module}/gitlab_runner.tpl", {
    app_cpu               = var.app_cpu
    app_image             = var.app_image
    app_memory            = var.app_memory
    gitlab_runner_token   = var.gitlab_runner_token
    app_region            = var.app_region
    additional_runner_tag = var.additional_runner_tag
    cloudflare_email      = var.cloudflare_email
    cloudflare_token      = var.cloudflare_token
  })
}

resource "aws_ecs_service" "gitlab_runner_tf" {
  count           = var.create_runner_terraform ? 1 : 0
  name            = "terraform"
  cluster         = aws_ecs_cluster.gitlab_runners[0].id
  task_definition = aws_ecs_task_definition.gitlab_runner_tf[0].arn
  desired_count   = var.create_runner_terraform ? 1 : 0
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.gitlab_runner_fargate[0].id]
    subnets = var.ecs_subnets
  }
}

resource "aws_iam_role" "ecs_tasks_gitlab_runner_tf" {
  count = var.create_runner_terraform ? 1 : 0
  name  = "ecs-task-gitlab-runner-tf"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
  EOF
}

resource "aws_iam_role_policy" "gitlab_runner_tf" {
  count = var.create_runner_terraform ? 1 : 0
  name  = "gitlab-runner-tf"
  role  = aws_iam_role.ecs_tasks_gitlab_runner_tf[0].id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListBucketVersions",
        "s3:GetObjectVersion",
	    "dynamodb:*",
	    "rds:*",
	    "cloudfront:*",
        "ec2:*",
        "route53:*",
        "lambda:*",
        "logs:*",
        "events:*",
        "sns:*",
        "sqs:*",
        "acm:*",
        "elasticloadbalancing:*",
        "autoscaling:*",
        "acm:ListCertificates",
        "iam:GetUser",
        "iam:GetInstanceProfile",
        "iam:GetRolePolicy",
        "iam:AddRoleToInstanceProfile",
        "iam:CreateInstanceProfile",
        "iam:DeleteInstanceProfile",
        "iam:GetPolicy",
        "iam:ListAccessKeys",
        "iam:GetUserPolicy",
        "iam:GetPolicyVersion",
        "iam:ListPolicyVersions",
        "iam:CreatePolicy",
        "iam:DeletePolicy",
        "iam:GetRole",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:DeleteRolePolicy",
        "iam:PassRole",
        "iam:PutRolePolicy",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:ListInstanceProfilesForRole",
        "iam:ListAttachedRolePolicies",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "ssm:*",
        "s3:*",
        "elasticmapreduce:*",
        "ecs:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": [
        "codebuild:ListProjects",
        "codebuild:BatchGetProjects",
        "codebuild:ListProjects",
        "codebuild:BatchGetBuilds",
        "codebuild:ListBuildsForProject",
        "codebuild:ListBuilds",
        "codebuild:StartBuild",
        "codebuild:StopBuild"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "iam:*",
      "Resource": "arn:aws:iam::*:role/aws-service-role/*"
    },
    {
        "Effect": "Allow",
        "Resource": "*",
        "Action": [
            "secretsmanager:ListSecrets",
            "secretsmanager:DescribeSecret",
            "secretsmanager:GetSecretValue",
            "secretsmanager:GetRandomPassword"
        ]
    },
    {
      "Effect":"Allow",
      "Action":[
        "kms:*"
      ],
      "Resource": [
        "${var.site_kms_key}"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": [
          "arn:aws:iam::${var.master_account}:role/cross-account-analytics-kms"
      ],
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy_gitlab_runner_tf" {
  count      = var.create_runner_terraform ? 1 : 0
  role       = aws_iam_role.ecs_tasks_gitlab_runner_tf[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
