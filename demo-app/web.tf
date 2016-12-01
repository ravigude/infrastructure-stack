provider "aws" {
  region = "us-east-1"
}

# Web  Modules

module "demo_web_elb" {
  source = "git::https://github.com/skdandamudi/tf_module_aws_elb_http.git"
  elb_name="demo_web_elb-${var.timestamp}"
  subnets = "subnet-2070f30d"
  security_groups = "sg-d5691ba8"
  elb_healthcheck_url = "TCP:22"
  instance_port = 8080
  instance_protocol = "http"
  unhealthy_threshold = "5"
  app_name = "demo"
  app_type = "web"
  app_env = "dev"

  }




module "demo_web_asg" {
source = "git::https://github.com/skdandamudi/tf_module_aws_asg.git"
  asg_name = "demo_web-dev"
  load_balancer_names =  "${module.demo_web_elb.elb_name}"
  availability_zones = "us-east-1a"
  vpc_zone_subnets = "subnet-2070f30d"
  security_groups = "sg-d5691ba8"
  ec2_user_login_key = "navitas-devops-ssh"
  ec2_iam_instance_role = "DevopsIAMROle"
  app_name = "demo"
  app_type = "web"
  app_env = "dev"
  health_check_grace_period = "1800"
  ec2_instance_type = "m3.medium"
  ec2_machine_image = "ami-b73b63a0"
  asg_maximum_number_of_instances = "1"
  asg_minimum_number_of_instances = "1"
  asg_desired_number_of_instances = "1"

}
