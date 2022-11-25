variable "data_ingress_server_name" {
  default = "data-ingress"
}

variable "region" {
  default = "eu-west-2"
}
variable "sft_port" {
  default =
}

variable "account" {}
variable "management_account" {}
variable "ecr_repository_name" {
  default = "dataworks-ingress-sft-agent"
}
variable "common_repo_tags" {}

variable "environment" {}

variable "env_prefix" {}

variable "certificate_authority_arn" {
}

variable "ecs_execution_role" {}

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
