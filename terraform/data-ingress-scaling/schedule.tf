resource "aws_autoscaling_schedule" "on" {
  count                  = contains(["preprod", "production"], var.environment) ? 1 : 0
  scheduled_action_name  = "on"
  desired_capacity       = var.asg_instance_count.desired[var.environment]
  max_size               = var.asg_instance_count.max[var.environment]
  min_size               = var.asg_instance_count.min[var.environment]
  recurrence             = "00 23 1 * *"
  time_zone              = var.time_zone
  autoscaling_group_name = var.data_ingress_autoscaling_group_name
}

resource "aws_autoscaling_schedule" "off" {
  count                  = contains(["preprod", "production"], var.environment) ? 1 : 0
  scheduled_action_name  = "off"
  desired_capacity       = var.asg_instance_count.off
  max_size               = var.asg_instance_count.off
  min_size               = var.asg_instance_count.off
  recurrence             = "00 23 4 * *"
  time_zone              = var.time_zone
  autoscaling_group_name = var.data_ingress_autoscaling_group_name
}

resource "aws_autoscaling_schedule" "test_on" {
  count                  = contains(["development", "qa"], var.environment) ? 1 : 0
  scheduled_action_name  = "test_scaling_on"
  desired_capacity       = var.asg_instance_count.test_desired
  max_size               = var.asg_instance_count.test_max
  recurrence             = format("%s %s", formatdate("mm hh DD MM", timeadd(timestamp(), "5m")), " *")
  time_zone              = var.time_zone
  autoscaling_group_name = var.data_ingress_autoscaling_group_name
}

resource "aws_autoscaling_schedule" "test_off" {
  count                  = contains(["development", "qa"], var.environment) ? 1 : 0
  scheduled_action_name  = "test_scaling_off"
  desired_capacity       = var.asg_instance_count.off
  max_size               = var.asg_instance_count.off
  recurrence             = format("%s %s", formatdate("mm hh DD MM", timeadd(timestamp(), "18m")), " *")
  time_zone              = var.time_zone
  autoscaling_group_name = var.data_ingress_autoscaling_group_name
}
