resource "aws_security_group" "fargte" {
  name        = "panelapp-fargate-${var.stack}-${var.env_name}"
  description = "group for panelapp fargte"
  vpc_id      = "${data.terraform_remote_state.infra.vpc_id}"

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_cluster")
  )}"
}

resource "aws_security_group_rule" "fargate_egress_amazon_london" {
  type              = "egress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["${data.aws_ip_ranges.amazon_london.cidr_blocks}"]
  security_group_id = "${aws_security_group.fargte.id}"
  description       = "Allow calls to aws London"
}

resource "aws_security_group_rule" "fargate_ingress_8080_alb" {
  type                     = "ingress"
  from_port                = "8080"
  to_port                  = "8080"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.panelapp_elb.id}"
  security_group_id        = "${aws_security_group.fargte.id}"
  description              = "Allow 8080 from elb"
}

# resource "aws_security_group_rule" "fargate_ingress_amazon_london" {
#   type        = "ingress"
#   from_port   = "0" 
#   to_port     = "65535"
#   protocol    = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]

#   # cidr_blocks       = ["${data.aws_ip_ranges.amazon_london.cidr_blocks}"]
#   security_group_id = "${aws_security_group.fargte.id}"
# }

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
  role = "${aws_iam_role.ecs_task_panelapp.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [{
      "Sid": "Stmt1559654322774",
      "Action": [
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:HeadBucket",
        "s3:ListBucket",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::panelapp-media"
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
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy_panelapp" {
  role       = "${aws_iam_role.ecs_task_panelapp.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
