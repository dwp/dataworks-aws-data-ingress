
resource "aws_acm_certificate" "data_ingress_server" {
  certificate_authority_arn = data.terraform_remote_state.mgmt_ca.outputs.root_ca.arn
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

resource "aws_ecs_task_definition" "data-ingress" {
  family                   = "data-ingress"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = var.task_definition_cpu[local.environment]
  memory                   = var.task_definition_memory[local.environment]
  task_role_arn            = aws_iam_role.data_ingress_server_task.arn
  execution_role_arn       = data.terraform_remote_state.common.outputs.ecs_task_execution_role.arn
  container_definitions    = "[${data.template_file.s3fs_definition.rendered}]"
  placement_constraints {
    type = "memberOf"
    expression = "attribute:ecs.availability-zone in ${local.az_ni}"
  }
  volume {
    name      = local.source_volume
    host_path = local.mount_path
  }
  tags = merge(local.common_repo_tags, { Name = local.name })
}

data "template_file" "s3fs_definition" {
  template = file("${path.module}/reserved_container_definition.tpl")
  vars = {
    name               = "ingress_sft_agent"
    group_name         = "ingress_sft_agent"
    cpu                = var.task_definition_cpu[local.environment]
    image_url          = "${local.account[local.management_account[local.environment]]}.dkr.ecr.${var.region}.amazonaws.com/${local.ecr_repository_name}"
    memory             = var.task_definition_memory[local.environment]
    memory_reservation = var.task_definition_memory[local.environment]
    user               = "root"
    ports              = jsonencode([])
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
        name  = "AWS_REGION",
        value = var.region
      },
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
        name  = "proxy_host",
        value = data.terraform_remote_state.aws_sdx.outputs.internet_proxy.host
      },
      {
        name  = "proxy_port",
        value = local.proxy_port
      },
      {
        name  = "non_proxied_endpoints",
        value = join(",", data.terraform_remote_state.aws_sdx.outputs.vpc.no_proxy_list)
      },
      {
        name  = "dks_fqdn",
        value = local.dks_fqdn
      },
      {
        name  = "CREATE_TEST_FILES",
        value = "true"
      },
      {
        name  = "TEST_DIRECTORY",
        value = local.sft_test_dir[local.environment]
      },
      {
        name  = "CONFIGURE_SSL",
        value = local.configure_ssl[local.environment]
      },
      {
        name  = "PROMETHEUS",
        value = "true"
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
        value : "false"
      },
      {
        name : "ni_id",
        value : aws_network_interface.di_ni.id
      },
      {
        name : "RENAME_FILE",
        value : local.rename_file
      },
    ])
  }
}

resource "aws_ecs_service" "data-ingress" {
  name            = "data-ingress"
  cluster         = aws_ecs_cluster.data_ingress_cluster.id
  task_definition = aws_ecs_task_definition.data-ingress.arn
  desired_count   = 0
  launch_type     = "EC2"
  network_configuration {
    security_groups = [aws_security_group.sft_agent_service.id]
    subnets         = [data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity[0].id]
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.data-ingress.arn
    container_name = "data-ingress"
  }

  tags = merge(local.common_repo_tags, { Name = "data-ingress-service" })
}

resource "aws_service_discovery_service" "data-ingress" {
  name = "data-ingress"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.data-ingress.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  tags = merge(local.common_repo_tags, { Name = "di-discovery-service" })
}

resource "aws_service_discovery_private_dns_namespace" "data-ingress" {
  name = "${local.environment}.services.${var.parent_domain_name}"
  vpc  = data.terraform_remote_state.aws_sdx.outputs.vpc.vpc.id
  tags = merge(local.common_repo_tags, { Name = "di-ds-dns-namespace" })
}
