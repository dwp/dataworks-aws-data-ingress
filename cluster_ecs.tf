resource "aws_ecs_cluster" "data_ingress_cluster" {
  name               = local.cluster_name
  capacity_providers = [aws_ecs_capacity_provider.data_ingress_cluster.name]

  tags = merge(
    local.common_repo_tags,
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
      setting,
    ]
  }
}

resource "aws_cloudwatch_log_group" "data_ingress_cluster" {
  name              = local.name_data_ingress_log_group
  retention_in_days = 180
  tags = merge(
    local.common_repo_tags,
    {
      Name = "data_ingress_cluster_logs"
    }
  )
}

resource "aws_ecs_capacity_provider" "data_ingress_cluster" {
  name = local.autoscaling_group_name
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.data_ingress_server.arn
    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 1
    }
  }
  lifecycle {
    ignore_changes = all
  }


  tags = merge(
    local.common_repo_tags,
    {
      Name = "data_ingress_cluster_logs"
    }
  )
}

//resource "aws_network_interface" "di_ni_sender" {
//  private_ip = ""
//  //  private_ip     = data.terraform_remote_state.aws_sdx.outputs.network_interface_ips_data_ingress[local.environment]
//  security_groups = [aws_security_group.data_ingress_server.id]
//  subnet_id       = data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity.0.id
//  tags            = merge(local.common_repo_tags, { Name = "di-ni-sender" })
//}
//
//resource "aws_network_interface" "di_ni_receiver" {
//  private_ip = ""
//  //  private_ip     = data.terraform_remote_state.aws_sdx.outputs.network_interface_ips_data_ingress[local.environment]
//  security_groups = [aws_security_group.data_ingress_server.id]
//  subnet_id       = data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity.0.id
//  tags            = merge(local.common_repo_tags, { Name = "di-ni-receiver" })
//}

resource "aws_autoscaling_group" "data_ingress_server" {
  name                  = local.autoscaling_group_name
  min_size              = local.data_ingress_server_asg_min[local.environment]
  max_size              = local.data_ingress_server_asg_max[local.environment]
  desired_capacity      = local.data_ingress_server_asg_desired[local.environment]
  protect_from_scale_in = false
  default_cooldown      = 30
  force_delete          = true
  vpc_zone_identifier   = [data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity[0].id]
  launch_template {
    id      = aws_launch_template.data_ingress_server.id
    version = aws_launch_template.data_ingress_server.latest_version
  }
  dynamic "tag" {
    for_each = local.data_ingress_server_tags_asg
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_schedule" "on" {
  scheduled_action_name  = "on"
  desired_capacity       = local.desired_capacity_on
  min_size               = local.min_capacity_on
  max_size               = local.max_capacity_on
  recurrence             = "30 23 2 * *"
  start_time             = timeadd(timestamp(), "5m")
  time_zone              = local.time_zone
  autoscaling_group_name = aws_autoscaling_group.data_ingress_server.name
}

resource "aws_autoscaling_schedule" "off" {
  scheduled_action_name  = "off"
  desired_capacity       = local.desired_capacity_off
  min_size               = local.min_capacity_off
  max_size               = local.max_capacity_off
  recurrence             = "30 23 4 * *"
  time_zone              = local.time_zone
  start_time             = timeadd(timestamp(), "7m")
  autoscaling_group_name = aws_autoscaling_group.data_ingress_server.name
}
//
//resource "aws_autoscaling_schedule" "test_on" {
//  count = contains(["development","qa"], local.environment) ? 1 : 0
//  scheduled_action_name  = "test_on"
//  desired_capacity       = local.desired_capacity_on
//  min_size               = local.min_capacity_on
//  max_size               = local.max_capacity_on
//  recurrence             = format("%s %s", formatdate("mm hh DD MM", timeadd(timestamp(), "4m")), " *")
//  start_time             = timeadd(timestamp(), "3m")
//  end_time               = timeadd(timestamp(), "1h")
//  time_zone              = local.time_zone
//  autoscaling_group_name = aws_autoscaling_group.data_ingress_server.name
//}
//
//resource "aws_autoscaling_schedule" "test_off" {
//  count = contains(["development","qa"], local.environment) ? 1 : 0
//  scheduled_action_name  = "test_off"
//  desired_capacity       = local.desired_capacity_off
//  min_size               = local.min_capacity_off
//  max_size               = local.max_capacity_off
//  recurrence             = format("%s %s", formatdate("mm hh DD MM", timeadd(timestamp(), "10m")), " *")
//  time_zone              = local.time_zone
//  start_time             = timeadd(timestamp(), "6m")
//  end_time               = timeadd(timestamp(), "1h")
//  autoscaling_group_name = aws_autoscaling_group.data_ingress_server.name
//}

resource "aws_launch_template" "data_ingress_server" {
  name                    = local.launch_template_name
  image_id                = var.ecs_hardened_ami_id
  instance_type           = var.data_ingress_server_ec2_instance_type[local.environment]
  disable_api_termination = false
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [aws_security_group.data_ingress_server.id]
    subnet_id                   = data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity.0.id
  }
  user_data = base64encode(templatefile("files/data_ingress_cluster_userdata.tpl", {
    cluster_name  = local.cluster_name
    instance_role = aws_iam_instance_profile.data_ingress_server.name
    region        = data.aws_region.current.name
    folder        = "/mnt/config"
    mnt_bucket    = data.terraform_remote_state.common.outputs.config_bucket.id
    name          = local.launch_template_name
    proxy_host    = data.terraform_remote_state.aws_sdx.outputs.internet_proxy.host
    proxy_port    = local.proxy_port
    secret_name   = local.secret_trendmicro
  }))
  instance_initiated_shutdown_behavior = "terminate"
  iam_instance_profile {
    arn = aws_iam_instance_profile.data_ingress_server.arn
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = merge(
    local.common_repo_tags,
    {
      Name = local.cluster_name
    }
  )
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      local.common_repo_tags,
      {
        Application  = "data_ingress_server"
        Name         = "data_ingress_server"
        Persistence  = "Ignore"
        AutoShutdown = "False"
        SSMEnabled   = local.data_ingress_server_ssmenabled[local.environment]
      }
    )
  }
  tag_specifications {
    resource_type = "volume"

    tags = merge(
      local.common_repo_tags,
      {
        Application = "data_ingress_server"
        Name        = "data_ingress_server"
      }
    )
  }
}

data "aws_secretsmanager_secret" "trendmicro" {
  name = local.secret_trendmicro
}
