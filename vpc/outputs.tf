output "vpc_id" {
  value = "${module.my_vpc.vpc_id}"
}

output "private_subnets" {
  value = ["${module.my_vpc.private_subnets}"]
}

output "public_subnets" {
  value = ["${module.my_vpc.public_subnets}"]
}

output "public_route_table_ids" {
  value = ["${module.my_vpc.public_route_table_ids}"]
}

output "private_route_table_ids" {
  value = ["${module.my_vpc.private_route_table_ids}"]
}

output "default_security_group_id" {
  value = "${module.my_vpc.default_security_group_id}"
}

output "web_security_group_id" {
  value = "${module.web_security_group.security_group_id}"
}

output "ssh_security_group_id" {
  value = "${module.ssh_security_group.security_group_id}"
}

output "app_security_group_id" {
  value = "${module.app_security_group.security_group_id}"
}
