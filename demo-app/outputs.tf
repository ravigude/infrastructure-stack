output "asg_name" {
	value = "${module.cwise_aws_waf_asg.asg_name}"
}

output "cwise_web_elb_dns_name" {
	value = "${module.cwise_aws_web_elb.elb_dns_name}"
}

output "cwise_web_elb_name" {
	value = "${module.cwise_aws_web_elb.elb_name}"
}

output "cwise_app_elb_dns_name" {
	value = "${module.cwise_aws_app_elb.elb_dns_name}"
}

output "cwise_app_elb_name" {
	value = "${module.cwise_aws_app_elb.elb_name}"
}
