resource "aws_s3_bucket_object" "data_ingress_sft_agent_config_receiver" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  key        = "${local.sft_agent_config_s3_prefix}/agent-config-receiver.yml"
  content    = data.template_file.data_ingress_sft_agent_config_tpl_receiver.rendered
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
}
resource "aws_s3_bucket_object" "data_ingress_sft_agent_config_sender" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  key        = "${local.sft_agent_config_s3_prefix}/agent-config-sender.yml"
  content    = data.template_file.data_ingress_sft_agent_config_tpl_sender.rendered
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
}

resource "aws_s3_bucket_object" "data_ingress_sft_agent_application_config_receiver" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  key        = "${local.sft_agent_config_s3_prefix}/agent-application-config-receiver.yml"
  content    = data.template_file.data_ingress_sft_agent_application_config_tpl_receiver.rendered
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
}

data "template_file" "data_ingress_sft_agent_config_tpl_sender" {
  template = file("${path.module}/sft_config/agent-config-sender.tpl")
  vars = {
    apiKey = local.api_key
  }
}

data "template_file" "data_ingress_sft_agent_config_tpl_receiver" {
  template = file("${path.module}/sft_config/agent-config-receiver.tpl")
  vars = {
    apiKey = local.api_key
  }
}

data "template_file" "data_ingress_sft_agent_application_config_tpl_receiver" {
  template = file("${path.module}/sft_config/agent-application-config-receiver.tpl")
  vars = {
    destination     = "${local.mount_path}/data-ingress/companies"
    source_filename = "prod217.csv"
  }
}

data "template_file" "data_ingress_sft_agent_application_config_tpl_sender" {
  template = file("${path.module}/sft_config/agent-application-config-sender.tpl")
  vars = {
//    ip = aws_network_interface.di_ni_receiver.private_ip
    ip = "aws_network_interface.di_ni_receiver.private_ip"
    port = local.sft_port
  }
}

resource "aws_s3_bucket_object" "data_ingress_sft_agent_application_config_sender" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  key        = "${local.sft_agent_config_s3_prefix}/agent-application-config-sender.yml"
  content    = data.template_file.data_ingress_sft_agent_application_config_tpl_sender.rendered
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
}
