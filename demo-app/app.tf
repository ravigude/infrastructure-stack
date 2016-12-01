# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

module "demo_app_elb" {
  source = "git::https://github.com/terraform/tf_aws_elb_http.git"
  elb_name="cwise-${var.app_env}-app-${var.timestamp}"
  subnets = "${lookup(var.app_elb_subnets, concat(var.aws_region, ".", var.app_env))}"
  security_groups = "${lookup(var.elb_app_security_groups, concat(var.aws_region, ".", var.app_env))}"
  elb_healthcheck_url = "${lookup(var.app_elb_healthcheckurl, concat(var.aws_region, ".", var.app_env))}"
  instance_port = 11400
  instance_protocol = "http"
  unhealthy_threshold = "${lookup(var.unhealthy_threshold, concat(var.aws_region, ".", var.app_env))}"
  app_name = "${var.app_name}"
  app_type = "app"
  app_env = "${var.app_env}"
  ASV = "${var.asv}"
  CMDBEnvironment = "${lookup(var.cmdb, var.app_env)}"
  OwnerContact = "${var.contact}"
  stack_name="${var.stack_name}"

}

# Userdata for app
resource "template_file" "app_userdata_template" {
    template = "${file("userdata.tpl")}"

    vars {
      HOST_NAME="${var.app_name}appec2${var.app_env}"
      APP_TYPE="app"
      APP_ENV="${var.app_env}"
      AWS_REGION="${var.aws_region}"
      SERVICE_USER="${var.service_user}"
      SSH_PUBLIC_KEY="${var.ssh_public_key}"
      STACK_NAME="${var.stack_name}"
      APP_VERSION="${var.app_version}"
    }
}

module "ami" {
    source = "git::https://github.com/arcus-terraform-modules/tf_aws_cof_ami"
    account = "${lookup(var.account, concat(var.aws_region, ".", var.app_env))}" # required, the Capital One AWS account name
    version = "${var.app_ami_version}" # optional, defaults to "latest" to get the latest AMI
    region = "${var.aws_region}" # optional, defaults to "us-east-1"
    distribution = "${var.app_os_distribution}" # optional, defaults to "rhel7" - options: rhel5, rhel6, rhel7, ubuntu1404, win08r2, win12r2
}

module "demo_app_asg" {
  source = "git::https://github.com/terraform/tf_aws_asg.git"
  asg_name = "${var.app_name}_app_${var.stack_name}"
  load_balancer_names =  "${module.demo_app_elb.elb_name}"
  availability_zones = "${lookup(var.azs, concat(var.aws_region, ".", var.app_env))}"
  vpc_zone_subnets = "${lookup(var.app_asg_subnets, concat(var.aws_region, ".", var.app_env))}"
  ASV = "${var.asv}"
  CMDBEnvironment = "${lookup(var.cmdb, var.app_env)}"
  OwnerContact = "${var.contact}"
  security_groups = "${lookup(var.app_asg_sgs, concat(var.aws_region, ".", var.app_env))}"
  ##ec2_user_data = "app-user-data.sh"
  ec2_user_data_raw = "${template_file.app_userdata_template.rendered}"
  ec2_user_login_key = "${lookup(var.ssh_key, concat(var.aws_region, ".", var.app_env))}"
  ec2_iam_instance_role = "${lookup(var.ec2_instance_role, concat(var.aws_region, ".", var.app_env))}"
  app_name = "${var.app_name}"
  app_type = "app"
  app_env = "${var.app_env}"
  health_check_grace_period = "1800"
  ec2_instance_type = "${lookup(var.app_instance_type, concat(var.aws_region, ".", var.app_env))}"
  ec2_machine_image = "${module.ami.id}"
  protect_from_shutdown_value = "exclude"
  protect_from_ami_shutdown_value = "exclude"
  asg_maximum_number_of_instances = "${lookup(var.app-max-instances, concat(var.aws_region, ".", var.app_env))}"
  asg_minimum_number_of_instances = "${lookup(var.app-min-instances, concat(var.aws_region, ".", var.app_env))}"
  asg_desired_number_of_instances = "${lookup(var.app-desired-instances, concat(var.aws_region, ".", var.app_env))}"
  stack_name="${var.stack_name}"
  snstopicarn = "${lookup(var.sns_arn, concat(var.aws_region, ".", var.app_env))}"
}

module "demo_app_asg_scale_up" {
  source = "git::https://github.com/terraform/tf_aws_autoscale_policy.git"
  app_name = "${var.app_name}"
  app_type = "app"
  app_env = "${var.app_env}"
  scale_type ="up"
  scale_adjustment = "1"
  asg_name = "${module.demo_app_asg.asg_id}"
}

module "demo_app_asg_scale_down" {
  source = "git::https://github.com/terraform/tf_aws_autoscale_policy.git"
  app_name = "${var.app_name}"
  app_type = "app"
  app_env = "${var.app_env}"
  scale_type ="down"
  scale_adjustment = "-1"
  asg_name = "${module.demo_app_asg.asg_id}"
}

module "demo_asg_app_stack_notifications" {
  source = "git::https://github.com/terraform/tf_aws_auto_scaling_notification.git"
  asg_names = "${module.demo_app_asg.asg_id}"
  asg_snstopicarn = "${lookup(var.sns_arn, concat(var.aws_region, ".", var.app_env))}"
}

module "demo_app_cpu_high_alarm" {
  source = "git::https://github.com/terraform/tf_aws_cloudwatch_metric_alarm.git"
  is_create_resource = "${lookup(var.is_create_alarm, concat(var.aws_region, ".", var.app_env))}"
  app_name = "${var.app_name}"
  app_type = "app"
  app_env = "${var.app_env}"
  alarm_type  = "cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = "3"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Average"
  threshold = "65"
  autoscaling_group_name = "${module.demo_app_asg.asg_name}"
  alarm_description ="scale up if CPU utlization is > 65% over 3 minutes"
  alarm_actions = "${module.demo_app_asg_scale_up.scale_policy_arn}"

}

module "demo_app_cpu_low_alarm" {
  source = "git::https://github.com/terraform/tf_aws_cloudwatch_metric_alarm.git"
  is_create_resource = "${lookup(var.is_create_alarm, concat(var.aws_region, ".", var.app_env))}"
  app_name = "${var.app_name}"
  app_type = "app"
  app_env = "${var.app_env}"
  alarm_type  = "cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "5"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Average"
  threshold = "35"
  autoscaling_group_name = "${module.demo_app_asg.asg_name}"
  alarm_description ="scale down if CPU utlization is <= 35% over 5 minutes"
  alarm_actions = "${module.demo_app_asg_scale_down.scale_policy_arn}"

}

module "demo_app_network_in_high_alarm" {
  source = "git::https://github.com/terraform/tf_aws_cloudwatch_metric_alarm.git"
  is_create_resource = "${lookup(var.is_create_alarm, concat(var.aws_region, ".", var.app_env))}"
  app_name = "${var.app_name}"
  app_type = "app"
  app_env = "${var.app_env}"
  alarm_type  = "nw-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = "1"
  metric_name = "NetworkIn"
  namespace = "AWS/EC2"
  period = "180"
  statistic = "Average"
  threshold = "80500000"
  autoscaling_group_name = "${module.demo_app_asg.asg_name}"
  alarm_description ="scale up if Network In is > 17500000 bytes over 3 minutes"
  alarm_actions = "${module.demo_app_asg_scale_up.scale_policy_arn}"

}

module "demo_app_network_in_low_alarm" {
  source = "git::https://github.com/terraform/tf_aws_cloudwatch_metric_alarm.git"
  is_create_resource = "${lookup(var.is_create_alarm, concat(var.aws_region, ".", var.app_env))}"
  app_name = "${var.app_name}"
  app_type = "app"
  app_env = "${var.app_env}"
  alarm_type  = "nw-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "NetworkIn"
  namespace = "AWS/EC2"
  period = "300"
  statistic = "Average"
  threshold = "75000"
  autoscaling_group_name = "${module.demo_app_asg.asg_name}"
  alarm_description ="scale down if Network In is <= 75000 bytes over 5 minutes"
  alarm_actions = "${module.demo_app_asg_scale_down.scale_policy_arn}"
}

#############  ELB 5XX Alarms #######

module "demo_app_elb_5XX_alarm" {
  source = "git::https://github.com/terraform/tf_aws_elb_cloudwatch_alarm.git"
  is_create_resource = "${lookup(var.is_create_alarm, concat(var.aws_region, ".", var.app_env))}"
  app_name = "${var.app_name}"
  app_type = "app"
  app_env = "${var.app_env}"
  alarm_type  = "elb_prod_5XX"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "HTTPCode_Backend_5XX"
  namespace = "AWS/ELB"
  period = "60"
  statistic = "Sum"
  threshold = "3"
  loadbalancer_name = "${module.demo_app_elb.elb_name}"
  alarm_description ="Alert if 1 5XX instance level status is thrown in 1 minute"
  alarm_actions = "${var.team_notifications_snstopicarn}"
}


#############  ELB SurgeQueue Alarms #######
module "demo_app_elb_surgequeue_alarm" {
  source = "git::https://github.com/terraform/tf_aws_elb_cloudwatch_alarm.git"
  is_create_resource = "${lookup(var.is_create_alarm, concat(var.aws_region, ".", var.app_env))}"
  app_name = "${var.app_name}"
  app_type = "app"
  app_env = "${var.app_env}"
  alarm_type  = "elb_surgequeue"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = "1"
  metric_name = "SurgeQueueLength"
  namespace = "AWS/ELB"
  period = "300"
  statistic = "Maximum"
  threshold = "1000"
  loadbalancer_name = "${module.demo_app_elb.elb_name}"
  alarm_description ="Alert if ELB Queue overloaded"
  alarm_actions = "${var.team_notifications_snstopicarn}"
}

#############  ELB Latency Alarms #######

module "demo_app_elb_latency_alarm" {
  source = "git::https://github.com/terraform/tf_aws_elb_cloudwatch_alarm.git"
  is_create_resource = "${lookup(var.is_create_alarm, concat(var.aws_region, ".", var.app_env))}"
  app_name = "${var.app_name}"
  app_type = "app"
  app_env = "${var.app_env}"
  alarm_type  = "elb_latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = "1"
  metric_name = "Latency"
  namespace = "AWS/ELB"
  period = "60"
  statistic = "Average"
  threshold = "2"
  loadbalancer_name = "${module.demo_app_elb.elb_name}"
  alarm_description ="Alert if ELB Latency"
  alarm_actions = "${var.team_notifications_snstopicarn}"
}


#############  ELB Spill over Alarms #######

module "demo_app_elb_spillover_alarm" {
  source = "git::https://github.com/terraform/tf_aws_elb_cloudwatch_alarm.git"
  is_create_resource = "${lookup(var.is_create_alarm, concat(var.aws_region, ".", var.app_env))}"
  app_name = "${var.app_name}"
  app_type = "app"
  app_env = "${var.app_env}"
  alarm_type  = "elb_spillover"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = "1"
  metric_name = "SpilloverCount"
  namespace = "AWS/ELB"
  period = "300"
  statistic = "Sum"
  threshold = "5"
  loadbalancer_name = "${module.demo_app_elb.elb_name}"
  alarm_description ="Alert if ELB Spillover"
  alarm_actions = "${var.team_notifications_snstopicarn}"
}
