resource "aws_autoscaling_schedule" "on" {
  count                  = var.environment == "production" ? 1 : 0
  scheduled_action_name  = "on"
  desired_capacity       = var.asg_instance_count.desired[var.environment]
  max_size               = var.asg_instance_count.max[var.environment]
  min_size               = var.asg_instance_count.min[var.environment]
  recurrence             = "00 23 1 * *"
  time_zone              = var.time_zone
  autoscaling_group_name = aws_autoscaling_group.data_ingress_server.name
}

resource "aws_autoscaling_schedule" "off" {
  count                  = var.environment == "production" ? 1 : 0
  scheduled_action_name  = "off"
  desired_capacity       = var.asg_instance_count.off
  max_size               = var.asg_instance_count.off
  min_size               = var.asg_instance_count.off
  recurrence             = "00 23 4 * *"
  time_zone              = var.time_zone
  autoscaling_group_name = aws_autoscaling_group.data_ingress_server.name
}
