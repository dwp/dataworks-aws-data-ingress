module "data-ingress-cluster" {
    source                                           = "./terraform/data-ingress-cluster"
    hcs_environment                                  = local.hcs_environment[local.environment]
    common_repo_tags                                 = local.common_repo_tags
    account                                          = local.account[local.environment]
    private_ips                                      = cidrhost(data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity[0].cidr_block, 14)
    subnet_id                                        = data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity.0.id
    asg_instance_count                               = local.asg_instance_count
    environment                                      = local.environment
    sdx_subnet_connectivity_zero                     = data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity[0].id
    sdx_subnet_connectivity_one                      = data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity[1].id
    sdx_vpc_id                                       = data.terraform_remote_state.aws_sdx.outputs.vpc.vpc.id
    sdx_prefix_list_id_s3                            = data.terraform_remote_state.aws_sdx.outputs.vpc.prefix_list_ids.s3
    data_ingress_server_ec2_instance_type            = var.data_ingress_server_ec2_instance_type
    config_bucket                                    = data.terraform_remote_state.common.outputs.config_bucket
    current_region                                   = data.aws_region.current.name
    secret_trendmicro                                = local.secret_trendmicro
    proxy                                            = data.terraform_remote_state.aws_sdx.outputs.internet_proxy
    acm_cert_arn                                     = module.data-ingress-sft-task.acm_cert_arn
    name                                             = local.name
    security_group_rules                             = local.security_group_rules
    sft_port                                         = local.sft_port
    monitoring_topic_arn                             = data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn
    stage_bucket                                     = local.stage_bucket
    companies_s3_prefix                              = local.companies_s3_prefix
    filename_prefix                                  = local.filename_prefix
    config_bucket_key_arn                            = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
    stage_bucket_key_arn                             = data.terraform_remote_state.common.outputs.stage_data_ingress_bucket_cmk.arn
    cert_bucket                                      = data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket
    ecs_hardened_ami_id                              = var.ecs_hardened_ami_id
    scale_down_time                                  = local.scale_down_time
    time_zone                                        = local.time_zone
    cwa_namespace                                    = local.cw_data_ingress_server_agent_namespace
    cwa_log_group_name                               = "${local.cw_data_ingress_server_agent_namespace}-${local.environment}"
    cwa_metrics_collection_interval                  = local.cw_agent_metrics_collection_interval
    cwa_cpu_metrics_collection_interval              = local.cw_agent_cpu_metrics_collection_interval
    cwa_disk_measurement_metrics_collection_interval = local.cw_agent_disk_measurement_metrics_collection_interval
    cwa_disk_io_metrics_collection_interval          = local.cw_agent_disk_io_metrics_collection_interval
    cwa_mem_metrics_collection_interval              = local.cw_agent_mem_metrics_collection_interval
    cwa_netstat_metrics_collection_interval          = local.cw_agent_netstat_metrics_collection_interval
    config_bucket_arn                                = local.config_bucket_arn
    config_bucket_cmk                                = local.config_bucket_cmk
    tenant                                           = local.tenant
    tenant_id                                        = local.tenant_id
    token                                            = local.token
    tanium1                                          = local.tanium1
    tanium2                                          = local.tanium2
    tanium_service_endpoint_dns                      = data.terraform_remote_state.aws_sdx.outputs.tanium_service_endpoint.dns
    tanium_service_endpoint_sg                       = data.terraform_remote_state.aws_sdx.outputs.tanium_service_endpoint.sg
}

output "network_interface_ip" {
    value = module.data-ingress-cluster.network_interface.ip
}

output "data_ingress_sg_id" {
    value = module.data-ingress-cluster.data_ingress_sg_id
}

module "data-ingress-sft-task" {
    source                                  = "./terraform/data-ingress-sft-task"
    environment                             = local.environment
    common_repo_tags                        = local.common_repo_tags
    sft_agent_version                       = local.sft_agent_version[local.environment]
    api_key                                 = local.data_ingress[local.environment].sft_agent_api_key
    env_prefix                              = local.env_prefix
    certificate_authority_arn               = data.terraform_remote_state.aws_certificate_authority.outputs.root_ca.arn
    ecs_execution_role                      = data.terraform_remote_state.common.outputs.ecs_task_execution_role.arn
    account                                 = local.account
    management_account                      = local.management_account
    sft_port                                = local.sft_port
    data_ingress_log_group_name             = module.data-ingress-cluster.data_ingress_log_group_name
    config_bucket                           = local.config_bucket
    sft_agent_config_s3_prefix              = local.sft_agent_config_s3_prefix
    stage_bucket                            = local.stage_bucket
    stage_bucket_kms_key_arn                = data.terraform_remote_state.common.outputs.stage_data_ingress_bucket_cmk.arn
    truststore_aliases                      = local.truststore_aliases
    truststore_certs                        = local.truststore_certs
    internet_proxy_host                     = data.terraform_remote_state.aws_sdx.outputs.internet_proxy.host
    non_proxied_endpoints                   = data.terraform_remote_state.aws_sdx.outputs.vpc.no_proxy_list
    filename_prefix                         = local.filename_prefix
    network_interface_id                    = module.data-ingress-cluster.network_interface.id
    network_interface_ip                    = module.data-ingress-cluster.network_interface.ip
    dks_fqdn                                = local.dks_fqdn
    secret_trendmicro                       = local.secret_trendmicro
    ecs_cluster_id                          = module.data-ingress-cluster.ecs_cluster_id
    sdx_vpc_id                              = data.terraform_remote_state.aws_sdx.outputs.vpc.vpc.id
    sdx_prefix_list_id_s3                   = data.terraform_remote_state.aws_sdx.outputs.vpc.prefix_list_ids.s3
    security_group_rules                    = local.security_group_rules
    config_bucket_kms_key_arn               = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
    cert_bucket                             = data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket
    ecs_hardened_ami_id                     = var.ecs_hardened_ami_id
    trendmicro_secret_arn                   = module.data-ingress-cluster.trendmicro_secret_arn
    companies_s3_prefix                     = local.companies_s3_prefix
    data_ingress_sg_id                      = module.data-ingress-cluster.data_ingress_sg_id
    agent_config_file                       = local.agent_config_file[local.environment]
}

module "data-ingress-check-file-landed" {
    source                                  = "./terraform/data-ingress-check-file-landed"
    environment                             = local.environment
    common_repo_tags                        = local.common_repo_tags
    scale_down_time                         = local.scale_down_time
    filename_prefix                         = local.filename_prefix
    stage_bucket                            = local.stage_bucket
    alarm_arn                               = module.data-ingress-cluster.no_file_landed.alarm_arn
    alarm_name                              = module.data-ingress-cluster.no_file_landed.alarm_name
    prefix                                  = local.companies_s3_prefix
    stage_bucket_kms_key_arn                = data.terraform_remote_state.common.outputs.stage_data_ingress_bucket_cmk.arn
}

