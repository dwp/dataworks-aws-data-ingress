resource "aws_autoscaling_schedule" "on" {
  scheduled_action_name  = "on"
  desired_capacity       = var.asg_instance_count.desired[var.environment]
  max_size               = var.asg_instance_count.max[var.environment]
  min_size               = var.asg_instance_count.min[var.environment]
  recurrence             = "00 23 1 * *"
  start_time             = timeadd(timestamp(), "6m")
  time_zone              = var.time_zone
  autoscaling_group_name = aws_autoscaling_group.data_ingress_server.name

}

resource "aws_autoscaling_schedule" "off" {
  scheduled_action_name  = "off"
  desired_capacity       = var.asg_instance_count.off
  max_size               = var.asg_instance_count.off
  min_size               = var.asg_instance_count.off
  recurrence             = "00 23 4 * *"
  time_zone              = var.time_zone
  start_time             = timeadd(timestamp(), "8m")
  autoscaling_group_name = aws_autoscaling_group.data_ingress_server.name

}

resource "aws_autoscaling_schedule" "test_on" {
  count                  = contains(["development", "qa"], var.environment) ? 1 : 0
  scheduled_action_name  = "test_scaling_on"
  desired_capacity       = var.asg_instance_count.test_desired
  max_size               = var.asg_instance_count.test_max
  recurrence             = format("%s %s", formatdate("mm hh DD MM", timeadd(timestamp(), "65m")), " *")
  start_time             = timeadd(timestamp(), "3m")
  end_time               = timeadd(timestamp(), "80m")
  time_zone              = var.time_zone
  autoscaling_group_name = aws_autoscaling_group.data_ingress_server.name
}

resource "aws_autoscaling_schedule" "test_off" {
  count                  = contains(["development", "qa"], var.environment) ? 1 : 0
  scheduled_action_name  = "test_scaling_off"
  desired_capacity       = var.asg_instance_count.off
  max_size               = var.asg_instance_count.off
  recurrence             = format("%s %s", formatdate("mm hh DD MM", timeadd(timestamp(), "78m")), " *")
  time_zone              = var.time_zone
  start_time             = timeadd(timestamp(), "4m")
  end_time               = timeadd(timestamp(), "80m")
  autoscaling_group_name = aws_autoscaling_group.data_ingress_server.name
}
