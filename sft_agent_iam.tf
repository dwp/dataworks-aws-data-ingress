data "aws_iam_policy_document" "sft_agent_task" {

  statement {
    sid = "PullIngressSFTAgentImageECRrepository"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = ["arn:aws:ecr:${var.region}:${local.account[local.management_account[local.environment]]}:repository/${local.ecr_repository_name}"]
  }

  statement {
    sid       = "AllowKMSDecryptdataIngress"
    actions   = ["kms:Decrypt"]
    resources = [data.terraform_remote_state.common.outputs.config_bucket_cmk.arn]
  }

  statement {
    sid     = "PullSFTAgentConfigS3dataIngress"
    actions = ["s3:GetObject"]
    resources = [
      "${data.terraform_remote_state.common.outputs.config_bucket.arn}/${aws_s3_bucket_object.data_ingress_sft_agent_config_receiver.key}",
      "${data.terraform_remote_state.common.outputs.config_bucket.arn}/${aws_s3_bucket_object.data_ingress_sft_agent_config_sender.key}",
      "${data.terraform_remote_state.common.outputs.config_bucket.arn}/${aws_s3_bucket_object.data_ingress_sft_agent_application_config_receiver.key}",
      "${data.terraform_remote_state.common.outputs.config_bucket.arn}/${aws_s3_bucket_object.data_ingress_sft_agent_application_config_sender.key}",
      "${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.arn}/*"
    ]
  }
  statement {
    sid     = "ListConfigBucketDI"
    actions = ["s3:ListBucket"]
    resources = [
      data.terraform_remote_state.common.outputs.config_bucket.arn,
      "${data.terraform_remote_state.common.outputs.config_bucket.arn}/*"
    ]
  }

  statement {
    sid    = "CertificateExportDI"
    effect = "Allow"
    actions = ["acm:ExportCertificate",
    "acm:GetCertificate"]
    resources = [aws_acm_certificate.data_ingress_server.arn]
  }
}

data "aws_iam_policy_document" "sft_task_ni" {
  statement {
    sid    = "niAttachmentPerission"
    effect = "Allow"
    actions = ["ecs:DescribeContainerInstances",
      "ec2:AttachNetworkInterface",
    "ec2:DescribeNetworkInterfaces"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "sft_task_ni" {
  role       = aws_iam_role.data_ingress_server_task.name
  policy_arn = aws_iam_policy.sft_task_ni.arn
}

resource "aws_iam_policy" "sft_task_ni" {
  name   = "SFTni"
  policy = data.aws_iam_policy_document.sft_task_ni.json
  lifecycle {ignore_changes = [tags]}
}

resource "aws_iam_policy" "sft_agent_task" {
  name        = "IngressSFTAgentTask"
  description = "Custom policy for the ingress sft agent task"
  policy      = data.aws_iam_policy_document.sft_agent_task.json
  lifecycle {ignore_changes = [tags]}
}

resource "aws_iam_role_policy_attachment" "sft_agent" {
  role       = aws_iam_role.data_ingress_server_task.name
  policy_arn = aws_iam_policy.sft_agent_task.arn
}

resource "aws_iam_role" "data_ingress_server_task" {
  name               = "DataIngressServer"
  assume_role_policy = data.aws_iam_policy_document.data_ingress_server_task_assume_role.json
  lifecycle {ignore_changes = [tags]}
}

data "aws_iam_policy_document" "data_ingress_server_task_assume_role" {
  statement {
    sid = "dataIngressServerTaskAssumeRole"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "data_ingress_server_task" {

  statement {
    sid    = "CertificateExportDI"
    effect = "Allow"
    actions = [
      "acm:ExportCertificate",
      "acm:GetCertificate"
    ]
    resources = [aws_acm_certificate.data_ingress_server.arn]
  }

  statement {
    sid       = "PublishMessageTrendMicro"
    actions   = ["sns:*"]
    resources = ["*"]
  }

    statement {
    sid       = "PublishedBucketKMSDecryptDI"
    actions   = ["kms:*"]
    resources = ["*"]

    //    resources = [data.terraform_remote_state.common.outputs.published_bucket_cmk.arn, data.terraform_remote_state.common.outputs.stage_data_ingress_bucket_cmk.arn]
  }

  statement {
    sid = "PublishedBucketReadDIlb"
    actions = [
      "s3:*"
    ]
    //    resources = [data.terraform_remote_state.common.outputs.data_ingress_stage_bucket.arn, "${data.terraform_remote_state.common.outputs.data_ingress_stage_bucket.arn}/*"]
    resources = ["*"]
  }
  statement {
    sid       = "DataIngressGetCAMgmtCertS3"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.arn}/*"]
  }
}

resource "aws_iam_policy" "data_ingress_server_task" {
  name        = "DataIngressServer"
  description = "Custom policy for data ingress server"
  policy      = data.aws_iam_policy_document.data_ingress_server_task.json
  lifecycle {ignore_changes = [tags]}
}

resource "aws_iam_role_policy_attachment" "data_ingress_server" {
  role       = aws_iam_role.data_ingress_server_task.name
  policy_arn = aws_iam_policy.data_ingress_server_task.arn
}

resource "aws_iam_role_policy_attachment" "data_ingress_server_export_certificate_bucket_read" {
  role       = aws_iam_role.data_ingress_server_task.name
  policy_arn = "arn:aws:iam::${local.account[local.environment]}:policy/CertificatesBucketRead"
}

resource "aws_iam_role_policy_attachment" "data_ingress_server_ebs_cmk_instance_encrypt_decrypt" {
  role       = aws_iam_role.data_ingress_server_task.name
  policy_arn = "arn:aws:iam::${local.account[local.environment]}:policy/EBSCMKInstanceEncryptDecrypt"
}
