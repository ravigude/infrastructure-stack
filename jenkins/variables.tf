variable "region" {
  description = "The AWS Region that the instances is created in"
  default ="us-east-1"
}

variable "ec2_instance_type" {
  description = "The EC2 instance type that is created "
	default ="m3.medium"
}

variable "ec2_user_login_key" {
  description = "The Pem key that need to "
}


variable "ec2_machine_image" {
  description = "The AMI to use"
}

variable "subnet_id" {
  description = "The VPC subnet the instance(s) will go in"
}

variable "security_groups" {
  description = "Security Group for ec2 instances"
}

variable "ec2_user_data" {
  description = "The path to a file with user_data for the instances"
}


variable "app_name" {
  description = "Application Name for the stack"
}

variable "app_env" {
  description = "Application env for the stack"
}

variable "number_of_instances" {
  description = "The number of instances you want to create"
  default = 1
}
