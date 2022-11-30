resource "aws_security_group" "data_ingress_server" {
  name        = "data_ingress_ecs"
  description = "Rules necessary for pulling container image, accessing vpc endpoints"
  vpc_id      = var.sdx_vpc_id
  tags        = merge(var.common_repo_tags, { Name = "data_ingress_cluster" })
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_security_group_rule" "server_ingress" {
  for_each                 = { for security_group_rule in var.security_group_rules : security_group_rule.name => security_group_rule }
  description              = "Allow inbound requests from ${each.value.name}"
  type                     = "ingress"
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = "tcp"
  security_group_id        = each.value.destination
  source_security_group_id = aws_security_group.data_ingress_server.id
}

resource "aws_security_group_rule" "server_egress" {
  for_each                 = { for security_group_rule in var.security_group_rules : security_group_rule.name => security_group_rule }
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
  prefix_list_ids   = [var.sdx_prefix_list_id_s3]
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.data_ingress_server.id
}

resource "aws_security_group_rule" "s3_http_egress" {
  description       = "Access to S3 http"
  type              = "egress"
  prefix_list_ids   = [var.sdx_prefix_list_id_s3]
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.data_ingress_server.id
}

resource "aws_security_group_rule" "s3_https_ingress" {
  description       = "Access to S3 https"
  type              = "ingress"
  prefix_list_ids   = [var.sdx_prefix_list_id_s3]
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.data_ingress_server.id
}

resource "aws_security_group_rule" "s3_http_ingress" {
  description       = "Access to S3 http"
  type              = "ingress"
  prefix_list_ids   = [var.sdx_prefix_list_id_s3]
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.data_ingress_server.id
}
//
//resource "aws_security_group_rule" "route_ports_egress" {
//  type              = "egress"
//  from_port         = 8080
//  to_port           = 8081
//  protocol          = "tcp"
//  cidr_blocks       = ["0.0.0.0/0"]
//  security_group_id = aws_security_group.data_ingress_server.id
//}
//
//resource "aws_security_group_rule" "route_ports_ingress" {
//  type              = "ingress"
//  from_port         = 8080
//  to_port           = 8081
//  protocol          = "tcp"
//  cidr_blocks       = ["0.0.0.0/0"]
//  security_group_id = aws_security_group.data_ingress_server.id
//}
//
//resource "aws_security_group_rule" "route_port_second_egress" {
//  type              = "egress"
//  from_port         = var.sft_port
//  to_port           = var.sft_port
//  protocol          = "tcp"
//  cidr_blocks       = ["0.0.0.0/0"]
//  security_group_id = aws_security_group.data_ingress_server.id
//}
//
//resource "aws_security_group_rule" "route_port_second_ingress" {
//  type              = "ingress"
//  from_port         = var.sft_port
//  to_port           = var.sft_port
//  protocol          = "tcp"
//  cidr_blocks       = ["0.0.0.0/0"]
//  security_group_id = aws_security_group.data_ingress_server.id
//}
