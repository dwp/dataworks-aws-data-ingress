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
    development = 2
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
    development = 3
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
  config_file = "agent-application-config.tpl"

  agent_config_file = "agent-config.tpl"

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
    preprod     = "s3://${local.env_certificate_bucket}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/server_certificates/sdx/service_1/sdx_mitm.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/server_certificates/sdx/service_2/sdx_mitm.pem"
    production  = "s3://${local.env_certificate_bucket}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/server_certificates/sdx/service_1/sdx_mitm.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/server_certificates/sdx/service_2/sdx_mitm.pem"
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
  sft_agent_config_s3_prefix = "component/data-ingress-sft"

  data_ingress = {
    development = {
      sft_agent_api_key        = "te5tapiKey"
      sft_agent_destination_ip = "127.0.0.1"
    }
    qa = {
      sft_agent_api_key        = "te5tapiKey"
      sft_agent_destination_ip = "127.0.0.1"
    }
    integration = {
      sft_agent_api_key        = "te5tapiKey"
      sft_agent_destination_ip = "127.0.0.1"
    }
    preprod = {
      sft_agent_api_key        = "te5tapiKey"
      sft_agent_destination_ip = "127.0.0.1"
    }
    production = {
      sft_agent_api_key        = "te5tapiKey"
      sft_agent_destination_ip = "127.0.0.1"
    }
  }
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
