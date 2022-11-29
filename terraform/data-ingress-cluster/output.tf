output "data_ingress_autoscaling_group_name" {
  value = aws_autoscaling_group.data_ingress_server.name
}

output "data_ingress_log_group_name" {
  value = aws_cloudwatch_log_group.data_ingress_cluster.name
}

output "network_interface" {
  value = {
    id = aws_network_interface.di_ni_receiver.id
    ip = aws_network_interface.di_ni_receiver.private_ip
  }

}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.data_ingress_cluster.id
}

output "trendmicro_secret_arn" {
  value = data.aws_secretsmanager_secret.trendmicro.arn
}
