resource "aws_security_group" "fargate" {
  name        = "panelapp-fargate-${var.stack}-${var.env_name}"
  description = "group for panelapp fargate"
  vpc_id      = data.terraform_remote_state.infra.vpc_id

  tags = merge(
    var.default_tags,
    map("Name", "panelapp_cluster")
  )
}

data "aws_ip_ranges" "amazon_region" {
  regions  = [var.region]
  services = ["amazon"]
}

resource "aws_security_group_rule" "fargate_egress" {
  type              = "egress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = [data.aws_ip_ranges.amazon_region.cidr_blocks]
  security_group_id = aws_security_group.fargate.id
  description       = "Allow calls to aws for the region"
}

resource "aws_security_group_rule" "fargate_smtp_egress" {
  type              = "egress"
  from_port         = 587
  to_port           = 587
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.fargate.id
  description       = "Allow calls to smtp server"
}

resource "aws_security_group_rule" "fargate_https_egress" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.fargate.id
  description       = "Allow calls to https server"
}

resource "aws_security_group_rule" "fargate_ingress_8080_alb" {
  type                     = "ingress"
  from_port                = "8080"
  to_port                  = "8080"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.panelapp_elb.id
  security_group_id        = aws_security_group.fargate.id
  description              = "Allow 8080 from elb"
}

resource "aws_iam_role" "ecs_task_panelapp" {
  name = "panelapp-${var.stack}-${var.env_name}"

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

resource "aws_iam_role_policy" "panelapp" {
  name = "panelapp-${var.stack}-${var.env_name}"
  role = aws_iam_role.ecs_task_panelapp.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [{
      "Sid": "Stmt1559654322774",
      "Action": [
        "s3:DeleteObject",
        "s3:PutObjectAcl",
        "s3:GetObjectAcl",
        "s3:GetObject",
        "s3:HeadBucket",
        "s3:ListBucket",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.panelapp_media.arn}/*",
        "${aws_s3_bucket.panelapp_statics.arn}/*",
        "${aws_s3_bucket.panelapp_scripts.arn}/*"
        ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "sqs:DeleteMessage",
        "sqs:GetQueueUrl",
        "sqs:ChangeMessageVisibility",
        "sqs:DeleteMessageBatch",
        "sqs:SendMessageBatch",
        "sqs:ReceiveMessage",
        "sqs:SendMessage",
        "sqs:GetQueueAttributes",
        "sqs:CreateQueue",
        "sqs:ChangeMessageVisibilityBatch"
      ],
      "Resource": "${aws_sqs_queue.panelapp.arn}"
    },
    {
      "Effect": "Allow",
      "Action": "sqs:ListQueues",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ],
      "Resource": [
        "${local.db_password_secret_arn}/*",
        "*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy_panelapp" {
  role       = aws_iam_role.ecs_task_panelapp.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
