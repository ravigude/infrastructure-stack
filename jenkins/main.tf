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
  security_groups =  "sg-d4691ba9"
  root_volume_size = "40"
  app_name = "devops_jenkins_master"
  app_env = "dev"
  ec2_iam_instance_role ="DevopsIAMROle"
  ec2_user_data = "user-data.sh"

}

module "my_jenkins_elb" {
source = "git::https://github.kdc.capitalone.com/terraform/tf_module_aws_elb_http_ec2.git"
elb_name="devops-jenkins-elb"
subnets = "subnet-2070f30d"
security_groups = "sg-d3691bae"
elb_healthcheck_url = "TCP:22"
instance_port = 8080
instance_protocol = "http"
app_name = "devops"
app_type = "app"
app_env = "dev"
stack_name="${var.stack_name}"
instances ="${module.my_jenkins.ec2_instance_id}"
}
