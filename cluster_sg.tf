resource "aws_security_group" "data_ingress_server" {
  name        = "data_ingress_cluster"
  description = "Rules necesary for pulling container image and accessing other metrics_cluster instances"
  vpc_id      = data.terraform_remote_state.aws_sdx.outputs.vpc.vpc.id
  tags        = merge(local.common_repo_tags, { Name = "data_ingress_cluster" })

  lifecycle {
    create_before_destroy = true
  }
}
