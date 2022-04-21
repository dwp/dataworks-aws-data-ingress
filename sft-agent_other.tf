
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
  container_definitions    = "[${data.template_file.sft_agent_definition.rendered}]"

  volume {
    name = "data-egress"
    docker_volume_configuration {
      scope         = "shared"
      autoprovision = true
      driver        = "local"
    }
  }
  tags = merge(local.common_repo_tags, { Name = local.name })
}

data "template_file" "sft_agent_definition" {
  template = file("${path.module}/reserved_container_definition.tpl")
  vars = {
    name          = "sft-agent"
    group_name    = "sft-agent"
    cpu           = var.task_definition_cpu[local.environment]
    image_url     = format("%s:%s", data.terraform_remote_state.management.outputs.ecr_sft_agent_url, var.sft_agent_image_version[local.environment])
    memory        = var.task_definition_memory[local.environment]
    memory_reservation = var.task_definition_memory[local.environment]
    user          = "nobody"
    ports         = jsonencode([9996])
    ulimits       = jsonencode([])
    log_group     = aws_cloudwatch_log_group.data_ingress_cluster.name
    region        = var.region
    config_bucket = data.terraform_remote_state.common.outputs.config_bucket.id
    s3_prefix     = "/data-ingress-e2e"
    essential     = true

    mount_points = jsonencode([
      {
        "container_path" : "/data-egress",
        "source_volume" : "data-egress"
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
        name  = "dks_fqdn",
        value = local.dks_fqdn
      },
      {
        name  = "PROMETHEUS",
        value = "true"
      }

    ])
  }
}

resource "aws_ecs_service" "data-ingress" {
  name            = "data-egress"
  cluster         = aws_ecs_cluster.data_ingress_cluster.id
  task_definition = aws_ecs_task_definition.data-ingress.arn
  desired_count   = 1
  launch_type     = "EC2"
  network_configuration {
    security_groups = [aws_security_group.data_ingress_server.id]
    subnets         = data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity.*.id
  }
  service_registries {
    registry_arn   = aws_service_discovery_service.data-ingress.arn
    container_name = "data-egress"
  }

  tags = merge(local.common_repo_tags, { Name = "service-di" })
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

  tags = merge(local.common_repo_tags, { Name = "service-discovery-di" })
}

resource "aws_service_discovery_private_dns_namespace" "data-ingress" {
  name = "${local.environment}.services.${var.parent_domain_name}"
  vpc  = data.terraform_remote_state.aws_sdx.outputs.vpc.vpc.id
  tags = merge(local.common_repo_tags, { Name = "namespace-DI" })
}
