provider "aws" {
    region = "${var.region}"
}

module "my_jenkins" {
  source = "git::https://github.com/skdandamudi/tf_module_aws_ec2.git"
  ec2_machine_image = "${var.ec2_machine_image}"
  number_of_instances = "${var.number_of_instances}"
  ec2_instance_type = "${var.ec2_instance_type}"
  ec2_user_login_key = "${var.ec2_user_login_key}"
  subnet_id = "${var.subnet_id}"
  security_groups =  "${var.security_groups)}"
  root_volume_size = "${var.root_volume_size}"
  app_name = "${var.app_name}"
  app_env = "${var.app_env}"

}
