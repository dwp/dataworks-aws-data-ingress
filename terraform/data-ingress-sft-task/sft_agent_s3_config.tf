resource "aws_s3_bucket_object" "data_ingress_sft_agent_config_receiver" {
  bucket     = var.config_bucket.id
  key        = "${var.sft_agent_config_s3_prefix}/agent-config-receiver.yml"
  content    = data.template_file.data_ingress_sft_agent_config_tpl_receiver.rendered
  kms_key_id = var.config_bucket_kms_key
}
resource "aws_s3_bucket_object" "data_ingress_sft_agent_config_sender" {
  bucket     = var.config_bucket.id
  key        = "${var.sft_agent_config_s3_prefix}/agent-config-sender.yml"
  content    = data.template_file.data_ingress_sft_agent_config_tpl_sender.rendered
  kms_key_id = var.config_bucket_kms_key
}

resource "aws_s3_bucket_object" "data_ingress_sft_agent_application_config_receiver" {
  bucket     = var.config_bucket.id
  key        = "${var.sft_agent_config_s3_prefix}/agent-application-config-receiver.yml"
  content    = data.template_file.data_ingress_sft_agent_application_config_tpl_receiver.rendered
  kms_key_id = var.config_bucket_kms_key
}

resource "aws_s3_bucket_object" "data_ingress_sft_agent_application_config_receiver_e2e" {
  bucket     = var.config_bucket.id
  key        = "${var.sft_agent_config_s3_prefix}/agent-application-config-receiver-e2e.yml"
  content    = data.template_file.data_ingress_sft_agent_application_config_tpl_receiver_e2e.rendered
  kms_key_id = var.config_bucket_kms_key
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
    destination                = "${var.mount_path}/${var.companies_s3_prefix}"
    destination_route_test     = "${var.mount_path}/${var.companies_s3_prefix}"
    source_filename            = "prod217.csv"
  }
}

data "template_file" "data_ingress_sft_agent_application_config_tpl_receiver_e2e" {
  template = file("${path.module}/sft_config/agent-application-config-receiver-e2e.tpl")
  vars = {
    destination_e2e     = "${var.mount_path}/e2e/${var.companies_s3_prefix}"
    source_filename     = "prod217.csv"
  }
}

data "template_file" "data_ingress_sft_agent_application_config_tpl_sender" {
  template = file("${path.module}/sft_config/agent-application-config-sender.tpl")
  vars = {
    ip   = network_interface_id
    port = var.sft_port
  }
}

resource "aws_s3_bucket_object" "data_ingress_sft_agent_application_config_sender" {
  bucket     = var.config_bucket.id
  key        = "${var.sft_agent_config_s3_prefix}/agent-application-config-sender.yml"
  content    = data.template_file.data_ingress_sft_agent_application_config_tpl_sender.rendered
  kms_key_id = var.config_bucket_kms_key
}
