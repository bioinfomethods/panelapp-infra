resource "aws_iam_user" "panelapp_ses" {
  name = "ses-user"

  tags = merge(
    var.default_tags,
    tomap({ "Name" : "ses-user" })
  )
}

resource "aws_iam_access_key" "ses" {
  user = aws_iam_user.panelapp_ses.name
}

resource "aws_iam_user_policy" "ses_access" {
  name = "panelapp-ses"
  user = aws_iam_user.panelapp_ses.name

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

resource "aws_ses_email_identity" "example" {
  email = var.admin_email
}

resource "aws_ses_domain_identity" "panelapp_ses_domain" {
  domain = var.cdn_alias
}

resource "aws_ses_domain_mail_from" "main" {
  domain           = aws_ses_domain_identity.panelapp_ses_domain.domain
  mail_from_domain = "mail.${var.cdn_alias}"
}

resource "aws_route53_record" "aws_ses_verification_record" {
  #   zone_id = data.terraform_remote_state.infra.outputs.public_dns_zone
  zone_id = var.public_dns_zone
  name    = "_amazonses.${var.cdn_alias}"
  type    = "TXT"
  ttl     = "600"
  records = [join("", aws_ses_domain_identity.panelapp_ses_domain.*.verification_token)]
}

resource "aws_ses_domain_dkim" "ses_domain_dkim" {
  domain = join("", aws_ses_domain_identity.panelapp_ses_domain.*.domain)
}

resource "aws_route53_record" "aws_ses_dkim_record" {
  count   = 3
  #   zone_id = data.terraform_remote_state.infra.outputs.public_dns_zone
  zone_id = var.public_dns_zone
  name    = "${element(aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens, count.index)}._domainkey.${var.cdn_alias}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_route53_record" "spf_mail_from" {
  #   zone_id = data.terraform_remote_state.infra.outputs.public_dns_zone
  zone_id = var.public_dns_zone
  name    = aws_ses_domain_mail_from.main.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}

resource "aws_route53_record" "spf_domain" {
  #   zone_id = data.terraform_remote_state.infra.outputs.public_dns_zone
  zone_id = var.public_dns_zone
  name    = var.cdn_alias
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}

resource "aws_route53_record" "mx" {
  #   zone_id = data.terraform_remote_state.infra.outputs.public_dns_zone
  zone_id = var.public_dns_zone
  name    = aws_ses_domain_mail_from.main.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.ap-southeast-2.amazonses.com"]
}
