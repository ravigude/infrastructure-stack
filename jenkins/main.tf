provider "aws" {
    region = "${var.region}"
}

module "my_jenkins" {
  source = "git::https://github.com/skdandamudi/tf_module_aws_ec2.git"
  ec2_machine_image = "ami-b73b63a0"
  number_of_instances = "1"
  ec2_instance_type = "m3.medium"
  ec2_user_login_key = "navitas-devops-ssh"
  subnet_id = "subnet-2370f30e"
  security_groups =  "sg-d4691ba9 "
  root_volume_size = "40"
  app_name = "devops_jenkins_master"
  app_env = "dev"
  ec2_iam_instance_role ="DevopsIAMROle"

}
