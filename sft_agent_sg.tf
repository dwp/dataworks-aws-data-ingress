resource "aws_security_group" "sft_agent_service" {
  name        = "ingress_sft_agent_service"
  description = "Control access to and from ingress sft agent service"
  vpc_id      = data.terraform_remote_state.aws_sdx.outputs.vpc.vpc.id

  tags = merge(
    local.common_repo_tags,
    {
      Name = "ingress_sft_agent_service"
    }
  )
}

resource "aws_security_group_rule" "sft_agent_service_s3_https" {
  description       = "Access to S3 https"
  type              = "egress"
  prefix_list_ids   = [data.terraform_remote_state.aws_sdx.outputs.vpc.prefix_list_ids.s3]
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.sft_agent_service.id
}

resource "aws_security_group_rule" "sft_agent_service_s3_http" {
  description       = "Access to S3 http"
  type              = "egress"
  prefix_list_ids   = [data.terraform_remote_state.aws_sdx.outputs.vpc.prefix_list_ids.s3]
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.sft_agent_service.id
}
//
//resource "aws_security_group_rule" "sft_agent_service_proxy_egress" {
//  description              = "Access to proxy"
//  type                     = "egress"
//  protocol                 = "tcp"
//  from_port                = local.internet_proxy_port
//  to_port                  = local.internet_proxy_port
//  source_security_group_id = aws_security_group.sft_agent_service.id
//  security_group_id        = data.terraform_remote_state.aws_sdx.outputs.internet_proxy.sg
//}
//
//resource "aws_security_group_rule" "sft_agent_service_proxy_ingress" {
//  description              = "Access to proxy"
//  type                     = "ingress"
//  protocol                 = "tcp"
//  from_port                = local.internet_proxy_port
//  to_port                  = local.internet_proxy_port
//  source_security_group_id = data.terraform_remote_state.aws_sdx.outputs.internet_proxy.sg
//  security_group_id        = aws_security_group.sft_agent_service.id
//}
//
//
//resource "aws_security_group_rule" "sft_agent_service_proxy_egres" {
//  description              = "Access to proxy"
//  type                     = "ingress"
//  protocol                 = "tcp"
//  from_port                = local.internet_proxy_port
//  to_port                  = local.internet_proxy_port
//  source_security_group_id = aws_security_group.sft_agent_service.id
//  security_group_id        = data.terraform_remote_state.aws_sdx.outputs.internet_proxy.sg
//}
//
//resource "aws_security_group_rule" "sft_agent_service_proxy_ingres" {
//  description              = "Access to proxy"
//  type                     = "egress"
//  protocol                 = "tcp"
//  from_port                = local.internet_proxy_port
//  to_port                  = local.internet_proxy_port
//  source_security_group_id = data.terraform_remote_state.aws_sdx.outputs.internet_proxy.sg
//  security_group_id        = aws_security_group.sft_agent_service.id
//}

resource "aws_security_group_rule" "sft_ingress" {
  for_each                 = { for security_group_rule in local.server_security_group_rules : security_group_rule.name => security_group_rule }
  description              = "Allow inbound requests from ${each.value.name}"
  type                     = "ingress"
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = "tcp"
  security_group_id        = each.value.destination
  source_security_group_id = aws_security_group.sft_agent_service.id
}

resource "aws_security_group_rule" "sft_egress" {
  for_each                 = { for security_group_rule in local.server_security_group_rules : security_group_rule.name => security_group_rule }
  description              = "Allow outbound requests to ${each.value.name}"
  type                     = "egress"
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = "tcp"
  source_security_group_id = each.value.destination
  security_group_id        = aws_security_group.sft_agent_service.id
}
