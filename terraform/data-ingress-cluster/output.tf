output "data_ingress_autoscaling_group" {
  value = aws_autoscaling_group.data_ingress_server
}

output "data_ingress_log_group_name" {
  value = aws_cloudwatch_log_group.data_ingress_cluster.name
}

output "network_interface_id" {
  value = aws_network_interface.di_ni_receiver.id
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.data_ingress_cluster.id
}
