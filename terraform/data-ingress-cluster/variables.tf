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
variable "secret_trendmicro" {}
variable "proxy" {}
variable "private_ips" {}
variable "subnet_id" {}
variable "config_bucket" {}
variable "current_region" {}
variable "asg_instance_count" {}
variable "environment" {}
variable "sdx_subnet_connectivity_zero" {}
variable "sdx_subnet_connectivity_one" {}
variable "data_ingress_server_ec2_instance_type" {}
variable "ecs_hardened_ami_id" {}
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
