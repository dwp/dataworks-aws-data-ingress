resource "aws_acm_certificate" "data_ingress_server" {
  certificate_authority_arn = data.terraform_remote_state.aws_certificate_authority.outputs.root_ca.arn
  domain_name               = "${local.data_ingress_server_name}.${local.env_prefix[local.environment]}dataworks.dwp.gov.uk"

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
  tags = merge(
    local.common_repo_tags,
    {
      Name = local.data_ingress_server_name
    },
  )
}

resource "aws_ecs_task_definition" "sft_agent_receiver" {
  family                   = "sft_agent_receiver"
  network_mode             = "host"
  requires_compatibilities = ["EC2"]
  cpu                      = var.task_definition_cpu[local.environment]
  memory                   = var.task_definition_memory[local.environment]
  task_role_arn            = aws_iam_role.data_ingress_server_task.arn
  execution_role_arn       = data.terraform_remote_state.common.outputs.ecs_task_execution_role.arn
  container_definitions    = "[${data.template_file.sft_agent_receiver_definition.rendered}]"

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in ${local.az_ni}"
  }
  volume {
    name      = local.source_volume
    host_path = local.mount_path
  }
  tags = merge(local.common_repo_tags, { Name = local.name })
}

resource "aws_ecs_task_definition" "sft_agent_sender" {
  family                   = "sft_agent_sender"
  count                    = local.test_sft[local.environment] == "true" ? 1 : 0
  network_mode             = "host"
  requires_compatibilities = ["EC2"]
  cpu                      = var.task_definition_cpu[local.environment]
  memory                   = var.task_definition_memory[local.environment]
  task_role_arn            = aws_iam_role.data_ingress_server_task.arn
  execution_role_arn       = data.terraform_remote_state.common.outputs.ecs_task_execution_role.arn
  container_definitions    = "[${data.template_file.sft_agent_sender_definition[0].rendered}]"
  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in ${local.az_sender}"
  }
  volume {
    name      = local.source_volume
    host_path = local.mount_path
  }
  tags = merge(local.common_repo_tags, { Name = "sft_agent_sender" })
}


data "template_file" "sft_agent_receiver_definition" {
  template = file("${path.module}/reserved_container_definition.tpl")
  vars = {
    name               = "sft_agent_receiver"
    group_name         = "sft_agent_receiver"
    cpu                = var.task_definition_cpu[local.environment]
    image_url          = "${local.account[local.management_account[local.environment]]}.dkr.ecr.${var.region}.amazonaws.com/${local.ecr_repository_name}"
    memory             = var.task_definition_memory[local.environment]
    memory_reservation = var.task_definition_memory[local.environment]
    user               = "root"
    ports              = jsonencode([8080, 8081, local.sft_port])
    ulimits            = jsonencode([])
    log_group          = aws_cloudwatch_log_group.data_ingress_cluster.name
    region             = var.region
    config_bucket      = data.terraform_remote_state.common.outputs.config_bucket.id
    s3_prefix          = local.sft_agent_config_s3_prefix
    essential          = true
    privileged         = true
    mount_points = jsonencode([
      {
        "container_path" : local.mount_path,
        "source_volume" : local.source_volume
      }
    ])
    environment_variables = jsonencode([
      {
        name : "AWS_DEFAULT_REGION",
        value : var.region
      },
      {
        name : "LOG_LEVEL",
        value : "DEBUG"
      },
      {
        name  = "STAGE_BUCKET",
        value = data.terraform_remote_state.common.outputs.data_ingress_stage_bucket.id
      },
      {
        name  = "KMS_KEY_ARN",
        value = data.terraform_remote_state.common.outputs.stage_data_ingress_bucket_cmk.arn
      },
      {
        name  = "acm_cert_arn",
        value = aws_acm_certificate.data_ingress_server.arn
      },
      {
        name  = "truststore_aliases",
        value = local.truststore_aliases[local.environment]
      },
      {
        name  = "truststore_certs",
        value = local.truststore_certs[local.environment]
      },
      {
        name  = "private_key_alias",
        value = "data_ingress"
      },
      {
        name  = "internet_proxy",
        value = data.terraform_remote_state.aws_sdx.outputs.internet_proxy.host
      },
      {
        name  = "non_proxied_endpoints",
        value = join(",", data.terraform_remote_state.aws_sdx.outputs.vpc.no_proxy_list)
      },
      {
        name  = "MNT_POINT",
        value = local.mount_path
      },
      {
        name : "FILENAME_PREFIX",
        value : local.filename_prefix
      },
      {
        name : "TEST_TREND_MICRO",
        value : var.test_trend_micro
      },
      //      {
      //        name : "NI_ID",
      //        value : aws_network_interface.di_ni_receiver.id
      //      },
      {
        name : "RENAME",
        value : "yes"
      },
      {
        name : "TYPE",
        value : "receiver"
      },
      {
        name  = "dks_fqdn",
        value = local.dks_fqdn
      },
    ])
  }
}

data "template_file" "sft_agent_sender_definition" {
  template = file("${path.module}/reserved_container_definition.tpl")
  count    = local.test_sft[local.environment] == "true" ? 1 : 0
  vars = {
    name               = "sft_agent_sender"
    group_name         = "sft_agent_sender"
    cpu                = var.task_definition_cpu[local.environment]
    image_url          = "${local.account[local.management_account[local.environment]]}.dkr.ecr.${var.region}.amazonaws.com/${local.ecr_repository_name}"
    memory             = var.task_definition_memory[local.environment]
    memory_reservation = var.task_definition_memory[local.environment]
    user               = "root"
    ports              = jsonencode([8080, 8081, local.sft_port])
    ulimits            = jsonencode([])
    log_group          = aws_cloudwatch_log_group.data_ingress_cluster.name
    region             = var.region
    config_bucket      = data.terraform_remote_state.common.outputs.config_bucket.id
    s3_prefix          = local.sft_agent_config_s3_prefix
    essential          = true
    privileged         = true

    mount_points = jsonencode([
      {
        "container_path" : local.mount_path,
        "source_volume" : local.source_volume
      }
    ])
    environment_variables = jsonencode([
      {
        name : "AWS_DEFAULT_REGION",
        value : var.region
      },
      {
        name : "LOG_LEVEL",
        value : "DEBUG"
      },
      {
        name  = "STAGE_BUCKET",
        value = data.terraform_remote_state.common.outputs.data_ingress_stage_bucket.id
      },
      {
        name  = "KMS_KEY_ARN",
        value = data.terraform_remote_state.common.outputs.stage_data_ingress_bucket_cmk.arn
      },
      {
        name  = "acm_cert_arn",
        value = aws_acm_certificate.data_ingress_server.arn
      },
      {
        name  = "truststore_aliases",
        value = local.truststore_aliases[local.environment]
      },
      {
        name  = "truststore_certs",
        value = local.truststore_certs[local.environment]
      },
      {
        name  = "private_key_alias",
        value = "data_ingress"
      },
      {
        name  = "internet_proxy",
        value = data.terraform_remote_state.aws_sdx.outputs.internet_proxy.host
      },
      {
        name  = "non_proxied_endpoints",
        value = join(",", data.terraform_remote_state.aws_sdx.outputs.vpc.no_proxy_list)
      },
      {
        name  = "MNT_POINT",
        value = local.mount_path
      },
      {
        name : "FILENAME_PREFIX",
        value : local.filename_prefix
      },
      {
        name : "TEST_TREND_MICRO",
        value : var.test_trend_micro
      },
      {
        name : "TYPE",
        value : "sender"
      },
      {
        name  = "dks_fqdn",
        value = local.dks_fqdn
      },
    ])
  }
}

resource "aws_ecs_service" "sft_agent_receiver" {
  name            = "sft_agent_receiver"
  cluster         = aws_ecs_cluster.data_ingress_cluster.id
  task_definition = aws_ecs_task_definition.sft_agent_receiver.arn
  desired_count   = 1
  launch_type     = "EC2"

  placement_constraints {
    type = "distinctInstance"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in ${local.az_ni}"
  }

  tags = merge(local.common_repo_tags, { Name = "data-ingress-receiver-service" })

}

resource "aws_ecs_service" "sft_agent_sender" {
  name            = "sft_agent_sender"
  count           = local.test_sft[local.environment] == "true" ? 1 : 0
  cluster         = aws_ecs_cluster.data_ingress_cluster.id
  task_definition = aws_ecs_task_definition.sft_agent_sender[0].arn
  desired_count   = 1
  launch_type     = "EC2"

  placement_constraints {
    type = "distinctInstance"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in ${local.az_sender}"
  }
  tags = merge(local.common_repo_tags, { Name = "data-ingress-sender-service" })
}
