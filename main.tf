module "data-ingress-cluster" {
    source                                  = "./terraform/data-ingress-cluster"
    common_repo_tags                        = local.common_repo_tags
    private_ips                             = cidrhost(data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity[0].cidr_block, 14)
    subnet_id                               = data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity.0.id
    asg_instance_count                      = local.asg_instance_count
    environment = local.environment
    sdx_subnet_connectivity_zero            = data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity[0].id
    sdx_subnet_connectivity_one             = data.terraform_remote_state.aws_sdx.outputs.subnet_sdx_connectivity[1].id
    ecs_hardened_ami_id                     = var.ecs_hardened_ami_id
    data_ingress_server_ec2_instance_type   = var.data_ingress_server_ec2_instance_type
    config_bucket                           = data.terraform_remote_state.common.outputs.config_bucket
}

module "data-ingress-scaling" {
    source                                  = "./terraform/data-ingress-scaling"
    asg_instance_count                      = local.asg_instance_count

}

module "data-ingress-sft" {
    source                                  = "./terraform/data-ingress-sft"

}
