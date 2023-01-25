resource "aws_s3_bucket_object" "data_ingress_sft_agent_config_receiver" {
  bucket     = var.config_bucket.id
  key        = "${var.sft_agent_config_s3_prefix}/agent-config-receiver.yml"
  content    = data.template_file.data_ingress_sft_agent_config_tpl_receiver.rendered
  kms_key_id = var.config_bucket_kms_key_arn
}
resource "aws_s3_bucket_object" "data_ingress_sft_agent_config_sender" {
  bucket     = var.config_bucket.id
  key        = "${var.sft_agent_config_s3_prefix}/agent-config-sender.yml"
  content    = data.template_file.data_ingress_sft_agent_config_tpl_sender.rendered
  kms_key_id = var.config_bucket_kms_key_arn
}

resource "aws_s3_bucket_object" "data_ingress_sft_agent_application_config_receiver" {
  bucket     = var.config_bucket.id
  key        = "${var.sft_agent_config_s3_prefix}/agent-application-config-receiver.yml"
  content    = data.template_file.data_ingress_sft_agent_application_config_tpl_receiver.rendered
  kms_key_id = var.config_bucket_kms_key_arn
}

resource "aws_s3_bucket_object" "data_ingress_sft_agent_application_config_receiver_e2e" {
  bucket     = var.config_bucket.id
  key        = "${var.sft_agent_config_s3_prefix}/agent-application-config-receiver-e2e.yml"
  content    = data.template_file.data_ingress_sft_agent_application_config_tpl_receiver_e2e.rendered
  kms_key_id = var.config_bucket_kms_key_arn
}

data "template_file" "data_ingress_sft_agent_config_tpl_sender" {
  template = file("${path.module}/sft_config/agent-config-sender.tpl")
  vars = {
    apiKey = var.api_key
  }
}

data "template_file" "data_ingress_sft_agent_config_tpl_receiver" {
  template = file("${path.module}/sft_config/agent-config-receiver.tpl")
  vars = {
    apiKey = var.api_key
  }
}

data "template_file" "data_ingress_sft_agent_application_config_tpl_receiver" {
  template = file("${path.module}/sft_config/agent-application-config-receiver.tpl")
  vars = {
    destination                = var.receiver_destination
    source_filename            = "(.+)"
  }
}

data "template_file" "data_ingress_sft_agent_application_config_tpl_receiver_e2e" {
  template = file("${path.module}/sft_config/agent-application-config-receiver-e2e.tpl")
  vars = {
    destination_e2e     =
    source_filename     = "prod217.csv"
  }
}

data "template_file" "data_ingress_sft_agent_application_config_tpl_sender" {
  template = file("${path.module}/sft_config/agent-application-config-sender.tpl")
  vars = {
    ip   = var.network_interface_ip
    port = var.sft_port
  }
}

resource "aws_s3_bucket_object" "data_ingress_sft_agent_application_config_sender" {
  bucket     = var.config_bucket.id
  key        = "${var.sft_agent_config_s3_prefix}/agent-application-config-sender.yml"
  content    = data.template_file.data_ingress_sft_agent_application_config_tpl_sender.rendered
  kms_key_id = var.config_bucket_kms_key_arn
}
