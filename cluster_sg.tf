resource "aws_security_group" "data_ingress_server" {
  name        = "data_ingress_cluster"
  description = "Rules necesary for pulling container image, accessing vpc endpoints"
  vpc_id      = data.terraform_remote_state.aws_sdx.outputs.vpc.vpc.id
  tags        = merge(local.common_repo_tags, { Name = "data_ingress_cluster" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "server_ingress" {
  for_each                 = { for security_group_rule in local.server_security_group_rules : security_group_rule.name => security_group_rule }
  description              = "Allow inbound requests from ${each.value.name}"
  type                     = "ingress"
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = "tcp"
  security_group_id        = each.value.destination
  source_security_group_id = aws_security_group.data_ingress_server.id
}

resource "aws_security_group_rule" "server_egress" {
  for_each                 = { for security_group_rule in local.server_security_group_rules : security_group_rule.name => security_group_rule }
  description              = "Allow outbound requests to ${each.value.name}"
  type                     = "egress"
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = "tcp"
  source_security_group_id = each.value.destination
  security_group_id        = aws_security_group.data_ingress_server.id
}

resource "aws_security_group_rule" "s3_https_egress" {
  description       = "Access to S3 https"
  type              = "egress"
  prefix_list_ids   = [data.terraform_remote_state.aws_sdx.outputs.vpc.prefix_list_ids.s3]
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.data_ingress_server.id
}

resource "aws_security_group_rule" "s3_http_egress" {
  description       = "Access to S3 http"
  type              = "egress"
  prefix_list_ids   = [data.terraform_remote_state.aws_sdx.outputs.vpc.prefix_list_ids.s3]
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.data_ingress_server.id
}

resource "aws_security_group_rule" "route_ports_egress" {
  type              = "egress"
  from_port         = 8080
  to_port           = 8081
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.data_ingress_server.id
}

resource "aws_security_group_rule" "route_ports_ingress" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8081
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.data_ingress_server.id
}

resource "aws_security_group_rule" "route_port_second_egress" {
  type              = "egress"
  from_port         = local.sft_port
  to_port           = local.sft_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.data_ingress_server.id
}

resource "aws_security_group_rule" "route_port_second_ingress" {
  type              = "ingress"
  from_port         = local.sft_port
  to_port           = local.sft_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.data_ingress_server.id
}
