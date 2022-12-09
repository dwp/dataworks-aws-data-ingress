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
