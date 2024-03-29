resource "aws_ecs_cluster" "data_ingress_cluster" {
  name               = var.cluster_name
  capacity_providers = [aws_ecs_capacity_provider.data_ingress_cluster.name]
  tags = merge(
    var.common_repo_tags,
    {
      Name = "data-ingress-cluster"
    }
  )

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_cloudwatch_log_group" "data_ingress_cluster" {
  name              = var.name_data_ingress_log_group
  retention_in_days = 180
  tags = merge(
    var.common_repo_tags,
    {
      Name = "data_ingress_cluster_logs"
    }
  )
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_ecs_capacity_provider" "data_ingress_cluster" {
  name = var.autoscaling_group_name
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.data_ingress_server.arn
    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 1
    }
  }

  tags = merge(
    var.common_repo_tags,
    {
      Name = "data_ingress_cluster_logs"
    }
  )
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_network_interface" "di_ni_receiver" {
  private_ips = [var.private_ips]
  security_groups = [aws_security_group.data_ingress_server.id]
  subnet_id       = var.subnet_id
  tags            = merge(var.common_repo_tags, { Name = "di-ni-receiver" })
  lifecycle {ignore_changes = [tags]}
}

resource "aws_autoscaling_group" "data_ingress_server" {
  name = var.autoscaling_group_name
  min_size              = var.asg_instance_count.min[var.environment]
  max_size              = var.asg_instance_count.max[var.environment]
  desired_capacity      = var.asg_instance_count.desired[var.environment]
  protect_from_scale_in = false
  default_cooldown      = 30
  force_delete          = true
  vpc_zone_identifier   = contains(["development","qa"], var.environment) ? [var.sdx_subnet_connectivity_zero, var.sdx_subnet_connectivity_one] : [var.sdx_subnet_connectivity_zero]
  # set mono subnet in higher envs to ensure the instance is started in the required az when capacity is equal to 1
  launch_template {
    id      = aws_launch_template.data_ingress_server.id
    version = aws_launch_template.data_ingress_server.latest_version
  }
  dynamic "tag" {
    for_each = merge(
    var.common_repo_tags,
    {
      Name        = var.cluster_name,
    }
  )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "data_ingress_server" {
  name                    = "data-ingress-launch-template" #changing the template name will affect the trend micro test
  image_id                = var.ecs_hardened_ami_id
  instance_type           = var.data_ingress_server_ec2_instance_type[var.environment]
  disable_api_termination = false
  lifecycle {
    create_before_destroy = true
    ignore_changes = [latest_version,tags]
  }
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [aws_security_group.data_ingress_server.id]
    subnet_id                   = var.sdx_subnet_connectivity_zero
  }
  user_data = base64encode(templatefile("files/data_ingress_cluster_userdata.tpl", {
    cluster_name                                     = var.cluster_name
    instance_role                                    = aws_iam_instance_profile.data_ingress_server.name
    region                                           = var.current_region
    folder                                           = "/mnt/config"
    mnt_bucket                                       = var.config_bucket.id
    name                                             = "data-ingress-launch-template"
    proxy_host                                       = var.proxy.host
    proxy_port                                       = var.proxy.port
    secret_name                                      = var.secret_trendmicro
    hcs_environment                                  = var.hcs_environment
    s3_scripts_bucket                                = var.config_bucket.id
    s3_script_logrotate                              = aws_s3_object.data_ingress_server_logrotate_script.id
    s3_script_cloudwatch_shell                       = aws_s3_object.data_ingress_server_cloudwatch_script.id
    s3_script_logging_shell                          = aws_s3_object.data_ingress_server_logging_script.id
    s3_script_config_hcs_shell                       = aws_s3_object.data_ingress_server_config_hcs_script.id
    cwa_namespace                                    = var.cwa_namespace
    cwa_log_group_name                               = var.cwa_log_group_name
    cwa_metrics_collection_interval                  = var.cwa_metrics_collection_interval
    cwa_cpu_metrics_collection_interval              = var.cwa_cpu_metrics_collection_interval
    cwa_disk_measurement_metrics_collection_interval = var.cwa_disk_measurement_metrics_collection_interval
    cwa_disk_io_metrics_collection_interval          = var.cwa_disk_io_metrics_collection_interval
    cwa_mem_metrics_collection_interval              = var.cwa_mem_metrics_collection_interval
    cwa_netstat_metrics_collection_interval          = var.cwa_netstat_metrics_collection_interval
    install_tenable                                  = local.tenable_install[local.environment]
    install_trend                                    = local.trend_install[local.environment]
    install_tanium                                   = local.tanium_install[local.environment]
    tanium_server_1                                  = var.tanium_service_endpoint_dns
    tanium_server_2                                  = var.tanium2
    tanium_env                                       = local.tanium_env[local.environment]
    tanium_port                                      = var.tanium_port_1
    tanium_log_level                                 = local.tanium_log_level[local.environment]
    tenant                                           = var.tenant
    tenantid                                         = var.tenant_id
    token                                            = var.token
    policyid                                         = local.policy_id[local.environment]
  }))
  instance_initiated_shutdown_behavior = "terminate"
  iam_instance_profile {
    arn = aws_iam_instance_profile.data_ingress_server.arn
  }
  tags = merge(
    var.common_repo_tags,
    {
      Name = var.cluster_name
    }
  )
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.common_repo_tags,
      {
        Name         = "data_ingress_server"
        SSMEnabled   = var.data_ingress_server_ssmenabled[var.environment]
      }
    )
  }
  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.common_repo_tags,
      {
        Name        = "data_ingress_server"
      }
    )
  }
}

data "aws_secretsmanager_secret" "trendmicro" {
  name = var.secret_trendmicro
}
