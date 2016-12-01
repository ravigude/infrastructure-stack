
output "demo_web_elb_dns_name" {
	value = "${module.demo_web_elb.elb_dns_name}"
}

output "demo_web_elb_name" {
	value = "${module.demo_web_elb.elb_name}"
}

output "demo_app_elb_dns_name" {
	value = "${module.demo_app_elb.elb_dns_name}"
}

output "demo_app_elb_name" {
	value = "${module.demo_app_elb.elb_name}"
}
