resource "aws_s3_bucket" "panelapp_statics" {
  bucket = "panelapp-statics"

  policy = ""

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_statics")
  )}"
}

resource "aws_s3_bucket" "panelapp_media" {
  bucket = "panelapp-media"

  policy = ""

  tags = "${merge(
    var.default_tags,
    map("Name", "panelapp_media")
  )}"
}
