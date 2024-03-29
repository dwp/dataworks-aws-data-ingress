variable "data_ingress_server_name" {
  default = "data-ingress"
}
variable "region" {
  default = "eu-west-2"
}
variable "data_ingress_log_group_name" {}
variable "sft_port" {}
variable "data_ingress_sg_id" {}
variable "account" {}
variable "management_account" {}
variable "ecr_repository_name" {
  default = "dataworks-ingress-sft-agent"
}
variable "sdx_prefix_list_id_s3" {}
variable "security_group_rules" {}
variable "sdx_vpc_id" {}
variable "ecs_cluster_id" {}
variable "common_repo_tags" {}
variable "network_interface_id" {}
variable "network_interface_ip" {}

variable "config_bucket_kms_key_arn" {}
variable "cert_bucket" {}
variable "environment" {}
variable "dks_fqdn" {}
variable "env_prefix" {}
variable "testing_on" {
  type    = string
  default = ""
}

variable "certificate_authority_arn" {
}
variable "secret_trendmicro" {}
variable "filename_prefix" {}
variable "non_proxied_endpoints" {}
variable "config_bucket" {}
variable "internet_proxy_host" {}
variable "sft_agent_config_s3_prefix" {}
variable "stage_bucket_kms_key_arn" {}
variable "stage_bucket" {}
variable "ecs_execution_role" {}
variable "truststore_aliases" {}
variable "truststore_certs" {}
variable "task_definition_memory" {
  type = map(string)
  default = {
    development = "10240"
    qa          = "10240"
    integration = "10240"
    preprod     = "26624"
    production  = "26624"
  }
}

variable "task_definition_cpu" {
  type = map(string)
  default = {
    development = "2048"
    qa          = "2048"
    integration = "2048"
    preprod     = "4096"
    production  = "4096"
  }
}

variable "az_ni" {
  default = "[eu-west-2a]"
}

variable "az_sender" {
  default = "[eu-west-2b]"
}

variable "mount_path" {
  default = "/mnt/point"
}

variable "source_volume" {
  default = "s3fs"
}

variable "ecs_hardened_ami_id" {
}
variable "companies_s3_prefix" {}
variable "api_key" {
}

variable "test_sft" {
  default = {
    development    = "true"
    qa             = "true"
    integration    = "false"
    management-dev = "false"
    preprod        = "false"
    production     = "false"
    management     = "false"
  }
}
variable "agent_config_file" {
    default     = "agent-config-with-tls.tpl"
    type        = string
    description = "The SFT configuration file to use. Defaults to TLS config."
  }

variable "trendmicro_secret_arn" {}

variable "receiver_destination" {
    default = {
    development    = "/mnt/point/e2e/data-ingress/companies"
    qa             = "/mnt/point/e2e/data-ingress/companies"
    integration    = "/mnt/point/e2e/data-ingress/companies"
    management-dev = "/mnt/point/e2e/data-ingress/companies"
    preprod        = "/mnt/point/data-ingress/companies"
    production     = "/mnt/point/data-ingress/companies"
    management     = "/mnt/point/data-ingress/companies"
  }
}

variable "sft_agent_version" {}

variable "sft_sender_http_protocol" {
  default = "http"
  description = "The HTTP protocol to use when communicating with the sft_recevier."
}