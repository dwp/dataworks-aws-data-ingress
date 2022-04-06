locals {
  cluster_name                = "data-ingress"
  launch_template_name        = "${local.cluster_name}-launch-template"
  name_data_ingress_log_group = "/app/data_ingress"
  env_prefix = {
    development = "dev."
    qa          = "qa."
    stage       = "stg."
    integration = "int."
    preprod     = "pre."
    production  = ""
  }
  mytags = merge(
    local.common_repo_tags,
    {
      Name = "dataIngressClusterLogs"
    }
  )
  data_ingress_server_asg_min = {
    development = 1
    qa          = 0
    integration = 0
    preprod     = 0
    production  = 0
  }
  autoscaling_group_name = "data-ingress-ag"
  data_ingress_server_asg_desired = {
    development = 2
    qa          = 2
    integration = 2
    preprod     = 2
    production  = 2
  }

  data_ingress_server_asg_max = {
    development = 2
    qa          = 2
    integration = 2
    preprod     = 2
    production  = 2
  }

  data_ingress_server_ssmenabled = {
    development = "True"
    qa          = "True"
    integration = "True"
    preprod     = "False"
    production  = "False"
  }

  crypto_workspace = {
    management-dev = "management-dev"
    management     = "management"
  }

  management_account = {
    development    = "management-dev"
    qa             = "management-dev"
    integration    = "management-dev"
    management-dev = "management-dev"
    preprod        = "management"
    production     = "management"
    management     = "management"
  }

  management_infra_account = {
    development    = "default"
    qa             = "default"
    integration    = "default"
    management-dev = "default"
    preprod        = "management"
    production     = "management"
    management     = "management"
  }


  data_ingress_server_name = "data-ingress-server"
  data_ingress_server_tags_asg = merge(
    local.common_repo_tags,
    {
      Name        = local.data_ingress_server_name,
      Persistence = "Ignore",
    }
  )
  cw_data_ingress_server_agent_namespace                = "/app/data-ingress"
  cw_agent_metrics_collection_interval                  = 60
  cw_agent_cpu_metrics_collection_interval              = 60
  cw_agent_disk_measurement_metrics_collection_interval = 60
  cw_agent_disk_io_metrics_collection_interval          = 60
  cw_agent_mem_metrics_collection_interval              = 60
  cw_agent_netstat_metrics_collection_interval          = 60
  dks_endpoint                                          = data.terraform_remote_state.crypto.outputs.dks_endpoint[local.environment]
  dks_fqdn                                              = data.terraform_remote_state.crypto.outputs.dks_fqdn[local.environment]

  service_security_group_rules = [
    {
      name : "VPC endpoints"
      port : 443
      destination : data.terraform_remote_state.aws_sdx.outputs.vpc.interface_vpce_sg_id
    },
    {
      name : "Internet proxy endpoints"
      port : 3128
      destination : data.terraform_remote_state.aws_sdx.outputs.internet_proxy.sg
    },
  ]


  data-ingress_group_name = "data-ingress"

  server_security_group_rules = [
    {
      name : "VPC endpoints"
      port : 443
      destination : data.terraform_remote_state.aws_sdx.outputs.vpc.interface_vpce_sg_id
    },
    {
      name : "Internet proxy endpoints"
      port : 3128
      destination : data.terraform_remote_state.aws_sdx.outputs.internet_proxy.sg
    },
  ]
}
