resource "aws_s3_bucket_object" "data_ingress_sft_agent_config" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  key        = "${local.sft_agent_config_s3_prefix}/agent-config.yml"
  content    = data.template_file.data_ingress_sft_agent_config_tpl.rendered
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
}

resource "aws_s3_bucket_object" "data_ingress_sft_agent_application_config" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  key        = "${local.sft_agent_config_s3_prefix}/agent-application-config.yml"
  content    = data.template_file.data_ingress_sft_agent_application_config_tpl.rendered
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
}

data "template_file" "data_ingress_sft_agent_config_tpl" {
  template = file("${path.module}/sft_config/${local.agent_config_file}")
  vars = {
    apiKey = local.data_ingress[local.environment].sft_agent_api_key
  }
}

data "template_file" "data_ingress_sft_agent_application_config_tpl" {
  template = file("${path.module}/sft_config/${local.config_file}")
  vars = {
    dest_bucket = data.terraform_remote_state.common.outputs.published_bucket.arn
    dest_prefix = "/data-ingress-e2e"
    error_bucket = data.terraform_remote_state.common.outputs.published_bucket.arn
    source_bucket = ""
  }
}
