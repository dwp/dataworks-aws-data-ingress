#resource "aws_security_group_rule" "sft_agent_service_s3_https" {
#  description       = "Access to S3 https"
#  type              = "egress"
#  prefix_list_ids   = [data.terraform_remote_state.aws_sdx.outputs.vpc.prefix_list_ids.s3]
#  protocol          = "tcp"
#  from_port         = 443
#  to_port           = 443
#  security_group_id = aws_security_group.data_ingress_server.id
#}
#
#resource "aws_security_group_rule" "sft_agent_service_s3_http" {
#  description       = "Access to S3 http"
#  type              = "egress"
#  prefix_list_ids   = [data.terraform_remote_state.aws_sdx.outputs.vpc.prefix_list_ids.s3]
#  protocol          = "tcp"
#  from_port         = 80
#  to_port           = 80
#  security_group_id = aws_security_group.data_ingress_server.id
#}

#resource "aws_security_group_rule" "sft_agent_service_to_sdx" {
#  description       = "Allow SFT agent to access SDX VIP for Crown Data Transfers"
#  type              = "egress"
#  protocol          = "tcp"
#  from_port         = var.sft_agent_port
#  to_port           = var.sft_agent_port
#  security_group_id = aws_security_group.sft_agent_service.id
#  cidr_blocks       = ["${data.terraform_remote_state.aws_sdx.outputs.sdx_f5_endpoint_1_vip}/32"]
#}