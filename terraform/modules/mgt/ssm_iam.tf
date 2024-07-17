resource "aws_iam_instance_profile" "ssm_session_profile" {
  name = "ssm_session_profile"
  role = aws_iam_role.ssm_session.name
}

resource "aws_iam_role" "ssm_session" {
  name = "ssm_session"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

## policies
resource "aws_iam_role_policy_attachment" "ssm_session_role" {
  role       = aws_iam_role.ssm_session.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "ssm_session" {
  role       = aws_iam_role.ssm_session.name
  policy_arn = aws_iam_policy.ssm_session.arn
}

resource "aws_iam_policy" "ssm_session" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListBucket",
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.aritfacts_bucket}",
        "arn:aws:s3:::${var.aritfacts_bucket}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters",
        "secretsmanager:GetSecretValue"
      ],
      "Resource": [
        "arn:aws:ssm:::parameter/*/database/master_password"
      ]
    },
    {
      "Sid": "Stmt1563367067850",
      "Action": [
        "kms:Describe*",
        "kms:List*",
        "kms:Get*",
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${var.kms_arn}"
      ]
    }
  ]
}
EOF
}
