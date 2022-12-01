resource "aws_security_group" "sft_agent_service" {
  name        = "ingress_sft_agent_service"
  description = "Control access to and from ingress sft agent service"
  vpc_id      = var.sdx_vpc_id
  tags = merge(
    var.common_repo_tags,
    {
      Name = "ingress_sft_agent_service"
    }
  )
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_security_group_rule" "sft_agent_service_s3_https" {
  description       = "Access to S3 https"
  type              = "egress"
  prefix_list_ids   = [var.sdx_prefix_list_id_s3]
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.sft_agent_service.id
}

resource "aws_security_group_rule" "sft_agent_service_s3_http" {
  description       = "Access to S3 http"
  type              = "egress"
  prefix_list_ids   = [var.sdx_prefix_list_id_s3]
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.sft_agent_service.id
}

resource "aws_security_group_rule" "sft_agent_service_s3_https_ingress" {
  description       = "Access to S3 https"
  type              = "ingress"
  prefix_list_ids   = [var.sdx_prefix_list_id_s3]
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.sft_agent_service.id
}

resource "aws_security_group_rule" "sft_agent_service_s3_http_ingress" {
  description       = "Access to S3 http"
  type              = "ingress"
  prefix_list_ids   = [var.sdx_prefix_list_id_s3]
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  security_group_id = aws_security_group.sft_agent_service.id
}


resource "aws_security_group_rule" "service_ingress" {
  for_each                 = { for security_group_rule in var.security_group_rules : security_group_rule.name => security_group_rule }
  description              = "Allow inbound requests from ${each.value.name}"
  type                     = "ingress"
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = "tcp"
  security_group_id        = each.value.destination
  source_security_group_id = aws_security_group.sft_agent_service.id
}

resource "aws_security_group_rule" "service_egress" {
  for_each                 = { for security_group_rule in var.security_group_rules : security_group_rule.name => security_group_rule }
  description              = "Allow outbound requests to ${each.value.name}"
  type                     = "egress"
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = "tcp"
  source_security_group_id = each.value.destination
  security_group_id        = aws_security_group.sft_agent_service.id
}


resource "aws_security_group_rule" "traffic_to_sft_sg_secondary_ports" {
  type              = "egress"
  from_port         = 8080
  to_port           = 8081
  protocol          = "tcp"
  source_security_group_id = var.data_ingress_sg_id
  security_group_id =  aws_security_group.sft_agent_service.id
}

resource "aws_security_group_rule" "traffic_from_sft_sg_secondary_ports" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8081
  protocol          = "tcp"
  source_security_group_id = aws_security_group.sft_agent_service.id
  security_group_id = var.data_ingress_sg_id
}

resource "aws_security_group_rule" "traffic_to_sft_sg_sft_port" {
  type              = "egress"
  from_port         = var.sft_port
  to_port           = var.sft_port
  protocol          = "tcp"
  source_security_group_id = var.data_ingress_sg_id
  security_group_id = aws_security_group.sft_agent_service.id
}

resource "aws_security_group_rule" "traffic_from_sft_sg_sft_port" {
  type              = "ingress"
  from_port         = var.sft_port
  to_port           = var.sft_port
  protocol          = "tcp"
  source_security_group_id = aws_security_group.sft_agent_service.id
  security_group_id = var.data_ingress_sg_id
}

resource "aws_security_group_rule" "traffic_to_sft_sg_secondary_ports_additional" {
  type              = "egress"
  from_port         = 8080
  to_port           = 8081
  protocol          = "tcp"
  source_security_group_id = aws_security_group.sft_agent_service.id
  security_group_id =  var.data_ingress_sg_id
}

resource "aws_security_group_rule" "traffic_from_sft_sg_secondary_ports_additional" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8081
  protocol          = "tcp"
  source_security_group_id = var.data_ingress_sg_id
  security_group_id =  aws_security_group.sft_agent_service.id
}

resource "aws_security_group_rule" "traffic_to_sft_sg_sft_port_additional" {
  type              = "egress"
  from_port         = var.sft_port
  to_port           = var.sft_port
  protocol          = "tcp"
  source_security_group_id = aws_security_group.sft_agent_service.id
  security_group_id = var.data_ingress_sg_id
}

resource "aws_security_group_rule" "traffic_from_sft_sg_sft_port_additional" {
  type              = "ingress"
  from_port         = var.sft_port
  to_port           = var.sft_port
  protocol          = "tcp"
  source_security_group_id = var.data_ingress_sg_id
  security_group_id =  aws_security_group.sft_agent_service.id
}
