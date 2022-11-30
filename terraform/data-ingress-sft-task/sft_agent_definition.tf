resource "aws_acm_certificate" "data_ingress_server" {
  certificate_authority_arn = var.certificate_authority_arn
  domain_name               = "${var.data_ingress_server_name}.${var.env_prefix[var.environment]}dataworks.dwp.gov.uk"
  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
  tags = merge(
    var.common_repo_tags,
    {
      Name = var.data_ingress_server_name
    },
  )

}

resource "aws_ecs_task_definition" "sft_agent_receiver" {
  family                   = "sft_agent_receiver"
  network_mode             = "host"
  requires_compatibilities = ["EC2"]
  cpu                      = var.task_definition_cpu[var.environment]
  memory                   = var.task_definition_memory[var.environment]
  task_role_arn            = aws_iam_role.data_ingress_server_task.arn
  execution_role_arn       = var.ecs_execution_role
  container_definitions    = "[${data.template_file.sft_agent_receiver_definition.rendered}]"

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in ${var.az_ni}"
  }
  volume {
    name      = var.source_volume
    host_path = var.mount_path
  }

  tags = merge(var.common_repo_tags, { Name = "sft-task-definition" })
}

resource "aws_ecs_task_definition" "sft_agent_sender" {
  family                   = "sft_agent_sender"
  count                    = var.test_sft[var.environment] == "true" ? 1 : 0
  network_mode             = "host"
  requires_compatibilities = ["EC2"]
  cpu                      = var.task_definition_cpu[var.environment]
  memory                   = var.task_definition_memory[var.environment]
  task_role_arn            = aws_iam_role.data_ingress_server_task.arn
  execution_role_arn       = var.ecs_execution_role
  container_definitions    = "[${data.template_file.sft_agent_sender_definition[0].rendered}]"

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in ${var.az_sender}"
  }
  volume {
    name      = var.source_volume
    host_path = var.mount_path
  }
  tags = merge(var.common_repo_tags, { Name = "sft_agent_sender" })
}


data "template_file" "sft_agent_receiver_definition" {
  template = file("${path.module}/reserved_container_definition.tpl")
  vars = {
    name               = "sft_agent_receiver"
    group_name         = "sft_agent_receiver"
    cpu                = var.task_definition_cpu[var.environment]
    image_url          = format("%s:%s", "${var.account[var.management_account[var.environment]]}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repository_name}", "latest")
    memory             = var.task_definition_memory[var.environment]
    memory_reservation = var.task_definition_memory[var.environment]
    user               = "0"
    ports              = jsonencode([8080, 8081, var.sft_port])
    ulimits            = jsonencode([])
    log_group          = var.data_ingress_log_group_name
    region             = var.region
    config_bucket      = var.config_bucket.id
    s3_prefix          = var.sft_agent_config_s3_prefix
    essential          = true
    privileged         = true
    mount_points = jsonencode([
      {
        "container_path" : var.mount_path,
        "source_volume" : var.source_volume
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
        value = var.stage_bucket.id
      },
      {
        name  = "KMS_KEY_ARN",
        value = var.stage_bucket_kms_key_arn
      },
      {
        name  = "acm_cert_arn",
        value = aws_acm_certificate.data_ingress_server.arn
      },
      {
        name  = "truststore_aliases",
        value = var.truststore_aliases[var.environment]
      },
      {
        name  = "truststore_certs",
        value = var.truststore_certs[var.environment]
      },
      {
        name  = "private_key_alias",
        value = "data_ingress"
      },
      {
        name  = "internet_proxy",
        value = var.internet_proxy_host
      },
      {
        name  = "non_proxied_endpoints",
        value = join(",", var.non_proxied_endpoints)
      },
      {
        name  = "MNT_POINT",
        value = var.mount_path
      },
      {
        name : "FILENAME_PREFIX",
        value : var.filename_prefix
      },
      {
        name : "NI_ID",
        value : var.network_interface_id
      },
      {
        name : "TYPE",
        value : "receiver"
      },
      {
        name  = "dks_fqdn",
        value = var.dks_fqdn
      },
      {
        name : "TEST_TREND_MICRO_ENV",
        value : var.environment
      },
      {
        name : "TEST_TREND_MICRO_ON",
        value : var.test_trend_micro_on
      },
      {
        name : "TREND_MICRO_SECRET_NAME",
        value : var.secret_trendmicro
      }
    ])
  }
}

data "template_file" "sft_agent_sender_definition" {
  template = file("${path.module}/reserved_container_definition.tpl")
  count    = var.test_sft[var.environment] == "true" ? 1 : 0
  vars = {
    name               = "sft_agent_sender"
    group_name         = "sft_agent_sender"
    cpu                = var.task_definition_cpu[var.environment]
    image_url          = format("%s:%s", "${var.account[var.management_account[var.environment]]}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repository_name}", "latest")
    memory             = var.task_definition_memory[var.environment]
    memory_reservation = var.task_definition_memory[var.environment]
    user               = "0"
    ports              = jsonencode([8080, 8081, var.sft_port])
    ulimits            = jsonencode([])
    log_group          = var.data_ingress_log_group_name
    region             = var.region
    config_bucket      = var.config_bucket.id
    s3_prefix          = var.sft_agent_config_s3_prefix
    essential          = true
    privileged         = true

    mount_points = jsonencode([
      {
        "container_path" : var.mount_path,
        "source_volume" : var.source_volume
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
        value = var.stage_bucket.id
      },
      {
        name  = "KMS_KEY_ARN",
        value = var.stage_bucket_kms_key_arn
      },
      {
        name  = "acm_cert_arn",
        value = aws_acm_certificate.data_ingress_server.arn
      },
      {
        name  = "truststore_aliases",
        value = var.truststore_aliases[var.environment]
      },
      {
        name  = "truststore_certs",
        value = var.truststore_certs[var.environment]
      },
      {
        name  = "private_key_alias",
        value = "data_ingress"
      },
      {
        name  = "internet_proxy",
        value = var.internet_proxy_host
      },
      {
        name  = "non_proxied_endpoints",
        value = join(",", var.non_proxied_endpoints)
      },
      {
        name  = "MNT_POINT",
        value = var.mount_path
      },
      {
        name : "FILENAME_PREFIX",
        value : var.filename_prefix,
      },
      {  name : "TYPE",
        value : "sender"
      },
      {
        name  = "dks_fqdn",
        value = var.dks_fqdn
      }
    ])
  }
}

resource "aws_ecs_service" "sft_agent_receiver" {
  name            = "sft_agent_receiver"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.sft_agent_receiver.arn
  desired_count   = 1
  launch_type     = "EC2"

  placement_constraints {
    type = "distinctInstance"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in ${var.az_ni}"
  }

  tags = merge(var.common_repo_tags, { Name = "data-ingress-receiver-service" })

}

resource "aws_ecs_service" "sft_agent_sender" {
  name            = "sft_agent_sender"
  count           = var.test_sft[var.environment] == "true" ? 1 : 0
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.sft_agent_sender[0].arn
  desired_count   = 1
  launch_type     = "EC2"

  placement_constraints {
    type = "distinctInstance"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in ${var.az_sender}"
  }
  tags = merge(var.common_repo_tags, { Name = "data-ingress-sender-service" })
}
