# FIXME these should be moved in the files creating the resources using each template


# FIXME These two IP ranges must be generalised. They must be related to the region the stack is deployed to.
#       For SES SMTP we must use a separate variable to define the Region of the SMTP server
data "aws_ip_ranges" "amazon_london" {
  regions  = ["eu-west-2"]
  services = ["amazon"]
}

# FIXME This does not seem to be used
data "aws_ip_ranges" "amazon_ireland" {
  regions  = ["eu-west-1"]
  services = ["amazon"]
}
