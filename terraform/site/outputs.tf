output "public_zone_id" {
  value = "${coalesce(join("", aws_route53_zone.public.*.id), "not_created")}"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "private_subnets" {
  value = "${module.vpc.private_subnets}"
}

output "public_subnets" {
  value = "${module.vpc.public_subnets}"
}

