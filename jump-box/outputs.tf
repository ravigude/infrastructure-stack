output "ec2_instance_id" {
  value = "${module.my_jump_box.ec2_instance_id}"
}

output "ec2_instance_ip" {
  value = "${module.my_jump_box.ec2_instance_ip}"
}
