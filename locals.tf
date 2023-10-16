locals {
  launch_template_name        = "data-ingress-launch-template"
  name_data_ingress_log_group = "/app/data_ingress"

  config_bucket_arn = data.terraform_remote_state.common.outputs.config_bucket["arn"]
  config_bucket_cmk = data.terraform_remote_state.common.outputs.config_bucket_cmk["arn"]

  env_prefix = {
    development = "dev."
    qa          = "qa."
    stage       = "stg."
    integration = "int."
    preprod     = "pre."
    production  = ""
  }
  sft_agent_version = {
    development = "latest"
    qa = "0.0.9"
    integration = "0.0.9"
    preprod = "0.0.9"
    production = "0.0.9"
  }

  agent_config_file = {
    development = "agent-config-receiver.tpl"
    qa          = "agent-config-receiver.tpl"
    integration = "agent-config-receiver.tpl"
    preprod     = "agent-config-receiver-with-tls.tpl"
    production  = "agent-config-receiver-with-tls.tpl"
  }

  scale_down_time                = "30 23 4 * *"
  time_zone                      = "Europe/London"
  autoscaling_group_name         = "data-ingress-ag"
  stage_bucket                   = data.terraform_remote_state.common.outputs.data_ingress_stage_bucket
  companies_s3_prefix            = "data-ingress/companies"
  companies_s3_prefix_route_test = "route-test/data-ingress/companies"
  config_bucket                  = data.terraform_remote_state.common.outputs.config_bucket
  asg_instance_count = {
    desired = {
      development = 2
      qa          = 2
      integration = 1
      preprod     = 1
      production  = 1
    }
    max = {
      development = 2
      qa          = 2
      integration = 1
      preprod     = 1
      production  = 1
    }
    min = {
      development = 0
      qa          = 0
      integration = 0
      preprod     = 0
      production  = 0
    }
    off          = 0
    test_desired = 2
    test_max     = 2
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
  filename_prefix = "BasicCompanyData"
  management_infra_account = {
    development    = "default"
    qa             = "default"
    integration    = "default"
    management-dev = "default"
    preprod        = "management"
    production     = "management"
    management     = "management"
  }

  truststore_aliases = {
    development = "dataworks_root_ca,dataworks_mgt_root_ca"
    qa          = "dataworks_root_ca,dataworks_mgt_root_ca"
    integration = "dataworks_root_ca,dataworks_mgt_root_ca"
    preprod     = "dataworks_root_ca,dataworks_mgt_root_ca,sdx1,sdx2"
    production  = "dataworks_root_ca,dataworks_mgt_root_ca,sdx1,sdx2"
  }
  env_certificate_bucket = "dw-${local.environment}-public-certificates"

  truststore_certs = {
    development = "s3://${local.env_certificate_bucket}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/ca_certificates/dataworks/dataworks_root_ca.pem"
    qa          = "s3://${local.env_certificate_bucket}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/ca_certificates/dataworks/dataworks_root_ca.pem"
    integration = "s3://${local.env_certificate_bucket}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/ca_certificates/dataworks/dataworks_root_ca.pem"
    preprod     = "s3://${local.env_certificate_bucket}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.aws_certificate_authority.outputs.public_cert_bucket.id}/server_certificates/sdx/service_1/sdx_mitm.pem,s3://${data.terraform_remote_state.aws_certificate_authority.outputs.public_cert_bucket.id}/server_certificates/sdx/service_2/sdx_mitm.pem"
    production  = "s3://${local.env_certificate_bucket}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.aws_certificate_authority.outputs.public_cert_bucket.id}/server_certificates/sdx/service_1/sdx_mitm.pem,s3://${data.terraform_remote_state.aws_certificate_authority.outputs.public_cert_bucket.id}/server_certificates/sdx/service_2/sdx_mitm.pem"
  }

  data_ingress_server_name = "data-ingress"
  data_ingress_server_tags_asg = merge(
    local.common_repo_tags,
    {
      Name        = local.data_ingress_server_name,
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
  security_group_rules = [
    {
      name : "VPC endpoints"
      port : 443
      destination : data.terraform_remote_state.aws_sdx.outputs.vpc.interface_vpce_sg_id
    },
    {
      name : "Internet proxy endpoints"
      port : local.proxy_port
      destination : data.terraform_remote_state.aws_sdx.outputs.internet_proxy.sg
    },
  ]

  sft_agent_config_s3_prefix = "component/data-ingress-sft"
  proxy_port                 = "3128"
  sft_port                   = "8091"
  secret_trendmicro          = "/concourse/dataworks/data_ingress/trendmicro"

  ## Tanium servers
  tanium1 = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).tanium[local.environment].server_1
  tanium2 = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).tanium[local.environment].server_2

  ## Trend config
  tenant    = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).trend.tenant
  tenant_id = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).trend.tenantid
  token     = jsondecode(data.aws_secretsmanager_secret_version.terraform_secrets.secret_binary).trend.token

}
