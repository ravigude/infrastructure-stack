provider "aws" {
    region = "${var.region}"
}

module "my_vpc" {
  source = "git::https://github.com/skdandamudi/tf_module_aws_vpc.git"
  name = "${var.app_name}-vpc"
  cidr = "10.0.0.0/16"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = "true"
  azs      = ["us-east-1a", "us-east-1b"]
  enable_dns_support = "true"
}


module "ssh_security_group" {
  source = "git::https://github.com/skdandamudi/tf_module_aws_sg_ssh.git"
  security_group_name ="${var.app_name}-ssh-sg"
  vpc_id="${module.my_vpc.vpc_id}"
  source_cidr_block = "0.0.0.0/0"
}

module "web_security_group" {
  source = "git::https://github.com/skdandamudi/tf_module_aws_sg_web.git"
  security_group_name="${var.app_name}-web-sg"
  vpc_id="${module.my_vpc.vpc_id}"
  source_cidr_block = "0.0.0.0/0"

}

module "app_security_group" {
  source = "git::https://github.com/skdandamudi/tf_module_aws_sg_app.git"
  security_group_name ="${var.app_name}-app-sg"
  vpc_id="${module.my_vpc.vpc_id}"

}


module "app_security_group_ingress_http_rule" {
  source = "git::https://github.com/skdandamudi/tf_module_aws_sg_rule.git"
  type = "ingress"
  from_port = "8080"
  to_port ="8080"
  protocol = "tcp"
  source_security_group_id = "${module.web_security_group.security_group_id}"
  security_group_id = "${module.app_security_group.security_group_id}"

}

module "web_security_group_egress_http_rule" {
  source = "git::https://github.com/skdandamudi/tf_module_aws_sg_rule.git"
  type = "egress"
  from_port = "8080"
  to_port ="8080"
  protocol = "tcp"
  source_security_group_id = "${module.app_security_group.security_group_id}"
  security_group_id = "${module.web_security_group.security_group_id}"

}
