output "ec2_instance_id" {
  value = "${module.my_jenkins.ec2_instance_id}"
}

output "ec2_instance_ip" {
  value = "${module.my_jenkins.ec2_instance_ip}"
}
