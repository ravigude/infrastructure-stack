provider "aws" {
    region = "${var.region}"
}

module "my_sonar" {
  source = "git::https://github.com/skdandamudi/tf_module_aws_ec2.git"
   ec2_machine_image = "ami-b73b63a0"
  number_of_instances = "1"
  ec2_instance_type = "t2.micro"
  ec2_user_login_key = "VariQSSH"
  subnet_id = "subnet-e0494ca9"
  security_groups =  "sg-6b204517"
  root_volume_size = "20"
  app_name = "devops_sonar"
  app_env = "dev"
  ec2_iam_instance_role ="DevopsIAMROle"
  ec2_user_data = "user-data.sh"

}

module "my_jenkins_elb" {
source = "git::https://github.com/skdandamudi/tf_module_aws_elb_http_ec2.git"
elb_name="devops-sonar-elb"
internal_elb="false"
subnet_id = "subnet-e0494ca9"
security_groups =  "sg-6b204517"
elb_healthcheck_url = "TCP:22"
instance_port = 8080
instance_protocol = "http"
app_name = "devops_sonar"
app_env = "dev"
instances ="${module.my_sonar.ec2_instance_id}"
}
