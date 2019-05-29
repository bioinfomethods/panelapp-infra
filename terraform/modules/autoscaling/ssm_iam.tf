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

resource "aws_iam_role_policy_attachment" "ssm_session_role" {
  role       = "${aws_iam_role.ssm_session.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_instance_profile" "ssm_session_profile" {
  name = "ssm_session_profile"
  role = "${aws_iam_role.ssm_session.name}"
}
