variable "common_repo_tags" {
}
variable "cluster_name" {
  default = "data-ingress"
}
variable "name_data_ingress_log_group" {
  default = "/app/data_ingress"
}
variable "autoscaling_group_name" {
  default = "data-ingress-ag"
}
variable "stage_bucket" {}
variable "filename_prefix" {}
variable "companies_s3_prefix" {}
variable "monitoring_topic_arn" {}
variable "sft_port" {}
variable "cert_bucket" {}
variable "config_bucket_key_arn" {}
variable "sdx_prefix_list_id_s3" {}
variable "security_group_rules" {}
variable "name" {}
variable "sdx_vpc_id" {}
variable "secret_trendmicro" {}
variable "proxy" {}
variable "private_ips" {}
variable "subnet_id" {}
variable "config_bucket" {}
variable "current_region" {}
variable "asg_instance_count" {}
variable "scale_down_time" {}
variable "environment" {}
variable "hcs_environment" {}
variable "sdx_subnet_connectivity_zero" {}
variable "sdx_subnet_connectivity_one" {}
variable "data_ingress_server_ec2_instance_type" {}
variable "time_zone" {}
variable "ecs_hardened_ami_id" {
  default = ""
}
variable "region" {
  default = "eu-west-2"
}
variable "account" {}
variable "data_ingress_server_ssmenabled" {
  default = {
    development = "True"
    qa = "True"
    integration = "True"
    preprod = "False"
    production = "False"
  }
}
variable "acm_cert_arn" {}
variable "stage_bucket_key_arn" {}

variable "cwa_namespace" {}
variable "cwa_log_group_name" {}
variable "cwa_metrics_collection_interval" {}
variable "cwa_cpu_metrics_collection_interval" {}
variable "cwa_disk_measurement_metrics_collection_interval" {}
variable "cwa_disk_io_metrics_collection_interval" {}
variable "cwa_mem_metrics_collection_interval" {}
variable "cwa_netstat_metrics_collection_interval" {}

variable "config_bucket_arn"{}
variable "config_bucket_cmk"{}


variable "tanium_port_1" {
  description = "tanium port 1"
  type        = string
  default     = "16563"
}

variable "tanium_port_2" {
  description = "tanium port 2"
  type        = string
  default     = "16555"
}

variable "tenant" {
  description = "Trend tenant"
  type        = string
}

variable "tenant_id" {
  description = "Trend tenantid"
  type        = string
}

variable "token" {
  description = "Trend tenant"
  type        = string
}
