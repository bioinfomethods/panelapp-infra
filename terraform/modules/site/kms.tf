resource "aws_kms_key" "site" {
  description = "${var.stack} site key in ${var.region}"
  policy      = ""
}

resource "aws_kms_alias" "site" {
  name          = "alias/${var.stack}-${var.env_name}-site"
  target_key_id = "${aws_kms_key.site.key_id}"
}



resource "aws_kms_key" "rds_shared" {
  description = "${var.stack} RDS site key in ${var.region}"
  policy      = ""
}

resource "aws_kms_alias" "prod_rds_shared" {
  name          = "alias/${var.stack}-${var.env_name}-rds-site"
  target_key_id = "${aws_kms_key.rds_shared.key_id}"
}