resource "aws_iam_user" "panelapp_ses" {
  name = "ses-user"

  tags = "${merge(
    var.default_tags,
    map("Name", "ses-user")
  )}"
}

resource "aws_iam_access_key" "ses" {
  user = "${aws_iam_user.panelapp_ses.name}"
}

resource "aws_iam_user_policy" "ses_access" {
  name = "panelapp-ses"
  user = "${aws_iam_user.panelapp_ses.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "ses:SendRawEmail",
    "Resource": "*"
  }]
}
EOF
}
