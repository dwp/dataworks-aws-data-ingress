module "data-ingress-cluster" {
    source                                  = "./terraform/data-ingress-cluster"
    common_repo_tags                        = local.common_repo_tags
    private_ips                             = cidrhost(data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity[0].cidr_block, 14)
    subnet_id                               = data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity.0.id
    asg_instance_count                      = local.asg_instance_count
    environment                             = local.environment
    sdx_subnet_connectivity_zero            = data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity[0].id
    sdx_subnet_connectivity_one             = data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity[1].id
    ecs_hardened_ami_id                     = var.ecs_hardened_ami_id
    data_ingress_server_ec2_instance_type   = var.data_ingress_server_ec2_instance_type
    config_bucket                           = data.terraform_remote_state.common.outputs.config_bucket
    current_region                          = data.aws_region.current.name
    secret_trendmicro                       = local.secret_trendmicro
    proxy                                   = data.terraform_remote_state.aws_sdx.outputs.internet_proxy
    acm_cert_arn                            = module.data-ingress-sft.acm_cert_arn
}

module "data-ingress-scaling" {
    source                                  = "./terraform/data-ingress-scaling"
    asg_instance_count                      = local.asg_instance_count
    environment                             = local.environment
    data_ingress_autoscaling_group          = module.data-ingress-cluster.data_ingress_autoscaling_group
}

module "data-ingress-sft" {
    source                                  = "./terraform/data-ingress-sft"
    environment                             = local.environment
    common_repo_tags                        = local.common_repo_tags
    environment                             = local.environment
    env_prefix                              = local.env_prefix
    certificate_authority_arn               = data.terraform_remote_state.aws_certificate_authority.outputs.root_ca.arn
    ecs_execution_role                      = data.terraform_remote_state.common.outputs.ecs_task_execution_role.arn
    account                                 = local.account
    management_account  = local.management_account

}
