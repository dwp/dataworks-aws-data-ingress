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
      setting
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
}

resource "aws_network_interface" "di_ni_receiver" {

  private_ips = [var.private_ips]
  security_groups = [aws_security_group.data_ingress_server.id]
  subnet_id       = var.subnet_id
  tags            = merge(var.common_repo_tags, { Name = "di-ni-receiver" })
}


resource "aws_autoscaling_group" "data_ingress_server" {
  name = var.autoscaling_group_name
  min_size              = var.asg_instance_count.off
  max_size              = var.asg_instance_count.off
  desired_capacity      = var.asg_instance_count.off
  protect_from_scale_in = false
  default_cooldown      = 30
  force_delete          = true
  vpc_zone_identifier   = contains(["development","qa"], var.environment) ? [var.sdx_subnet_connectivity_zero, var.sdx_subnet_connectivity_zero] : [var.sdx_subnet_connectivity_zero]
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
      Persistence = "Ignore",
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
    ignore_changes = [latest_version]
  }
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [aws_security_group.data_ingress_server.id]
    subnet_id                   = var.sdx_subnet_connectivity_zero
  }
  user_data = base64encode(templatefile("files/data_ingress_cluster_userdata.tpl", {
    cluster_name  = var.cluster_name
    instance_role = aws_iam_instance_profile.data_ingress_server.name
    region        = data.aws_region.current.name
    folder        = "/mnt/config"
    mnt_bucket    = var.config_bucket.id
    name          = "data-ingress-launch-template"
    proxy_host    = data.terraform_remote_state.aws_sdx.outputs.internet_proxy.host
    proxy_port    = var.proxy_port
    secret_name   = var.secret_trendmicro
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
        Application  = "data_ingress_server"
        Name         = "data_ingress_server"
        Persistence  = "Ignore"
        AutoShutdown = "False"
        SSMEnabled   = var.data_ingress_server_ssmenabled[var.environment]
      }
    )
  }
  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.common_repo_tags,
      {
        Application = "data_ingress_server"
        Name        = "data_ingress_server"
      }
    )
  }
}

data "aws_secretsmanager_secret" "trendmicro" {
  name = var.secret_trendmicro
}
