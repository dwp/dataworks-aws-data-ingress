locals {
  cluster_name = "data-ingress"
  launch_template_name = "${local.cluster_name}-launch-template" #changing the template name will affect the trend micro test
  name_data_ingress_log_group = "/app/data_ingress"

  env_prefix = {
    development = "dev."
    qa = "qa."
    stage = "stg."
    integration = "int."
    preprod = "pre."
    production = ""
  }

  time_zone = "Europe/London"

  az_ni = "[eu-west-2a]"
  az_sender = "[eu-west-2b]"

  today_date = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())

  autoscaling_group_name = "data-ingress-ag"

  asg_instance_count = {
    desired = {
      development = 2
      qa = 0
      integration = 0
      preprod = 0
      production = 0
    }
    max = {
      development = 2
      qa = 0
      integration = 0
      preprod = 0
      production = 0
    }
    min = {
      development = 0
      qa = 0
      integration = 0
      preprod = 0
      production = 0
    }
    off = 2
    test_desired = 2
    test_max = 2
  }

  data_ingress_server_ssmenabled = {
    development = "True"
    qa = "True"
    integration = "True"
    preprod = "False"
    production = "False"
  }

  crypto_workspace = {
    management-dev = "management-dev"
    management     = "management"
  }

  management_account = {
    development = "management-dev"
    qa = "management-dev"
    integration = "management-dev"
    management-dev = "management-dev"
    preprod = "management"
    production = "management"
    management = "management"
  }

  filename_prefix = "BasicCompanyData"

  management_infra_account = {
    development = "default"
    qa = "default"
    integration = "default"
    management-dev = "default"
    preprod = "management"
    production = "management"
    management = "management"
  }

  truststore_aliases = {
    development = "dataworks_root_ca,dataworks_mgt_root_ca"
    qa = "dataworks_root_ca,dataworks_mgt_root_ca"
    integration = "dataworks_root_ca,dataworks_mgt_root_ca"
    preprod = "dataworks_root_ca,dataworks_mgt_root_ca,sdx1,sdx2"
    production = "dataworks_root_ca,dataworks_mgt_root_ca,sdx1,sdx2"
  }
  env_certificate_bucket = "dw-${local.environment}-public-certificates"

  truststore_certs = {
    development = "s3://${local.env_certificate_bucket}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/ca_certificates/dataworks/dataworks_root_ca.pem"
    qa = "s3://${local.env_certificate_bucket}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/ca_certificates/dataworks/dataworks_root_ca.pem"
    integration = "s3://${local.env_certificate_bucket}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/ca_certificates/dataworks/dataworks_root_ca.pem"
    preprod = "s3://${local.env_certificate_bucket}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/server_certificates/sdx/service_1/sdx_mitm.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/server_certificates/sdx/service_2/sdx_mitm.pem"
    production = "s3://${local.env_certificate_bucket}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/server_certificates/sdx/service_1/sdx_mitm.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/server_certificates/sdx/service_2/sdx_mitm.pem"
  }

  data_ingress_server_name = "data-ingress"
  data_ingress_server_tags_asg = merge(
  local.common_repo_tags,
  {
    Name = local.data_ingress_server_name,
    Persistence = "Ignore",
  }
  )
  cw_data_ingress_server_agent_namespace = "/app/data-ingress"
  cw_agent_metrics_collection_interval = 60
  cw_agent_cpu_metrics_collection_interval = 60
  cw_agent_disk_measurement_metrics_collection_interval = 60
  cw_agent_disk_io_metrics_collection_interval = 60
  cw_agent_mem_metrics_collection_interval = 60
  cw_agent_netstat_metrics_collection_interval = 60
  dks_endpoint = data.terraform_remote_state.crypto.outputs.dks_endpoint[local.environment]
  dks_fqdn = data.terraform_remote_state.crypto.outputs.dks_fqdn[local.environment]

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

  ecr_repository_name = "dataworks-ingress-sft-agent"
  sft_agent_config_s3_prefix = "component/data-ingress-sft"
  proxy_port = "3128"
  sft_port = "8091"
  api_key = "Te5tAp1Key"
  secret_trendmicro = "/concourse/dataworks/data_ingress/trendmicro"
  test_sft = {
    development = "true"
    qa = "true"
    integration = "false"
    management-dev = "false"
    preprod = "false"
    production = "false"
    management = "false"
  }

  mount_path = "/mnt/point"
  source_volume = "s3fs"
}
