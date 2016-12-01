provider "aws" {
    region = "${var.region}"
}

module "my_jump_box" {
  source = "git::https://github.com/skdandamudi/tf_module_aws_ec2.git"
  ec2_machine_image = "ami-b73b63a0"
  number_of_instances = "1"
  ec2_instance_type = "t2.micro"
  ec2_user_login_key = "navitas-devops-ssh"
  subnet_id = "subnet-2070f30d"
  security_groups =  "sg-d5691ba8"
  root_volume_size = "20"
  app_name = "devops_jumpbox"
  app_env = "dev"
  ec2_iam_instance_role ="DevopsIAMROle"
  ec2_user_data = "user-data.sh"

}
