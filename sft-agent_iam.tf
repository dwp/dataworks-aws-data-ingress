resource "aws_iam_role" "sft_agent_task" {
  name               = "SFTAgentTaskDi"
  assume_role_policy = data.aws_iam_policy_document.sft_agent_task_assume_role.json
}

data "aws_iam_policy_document" "sft_agent_task_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

  }
}

data "aws_iam_policy_document" "sft_agent_task" {

  statement {
    sid = "PullSFTAgentImageECRdataIngress"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = [data.terraform_remote_state.management.outputs.sft_agent_ecr_repository.arn]
  }

  statement {
    sid       = "AllowKMSDecryptdataIngress"
    actions   = ["kms:Decrypt"]
    resources = [data.terraform_remote_state.common.outputs.config_bucket_cmk.arn]
  }

  statement {
    sid = "PullSFTAgentConfigS3dataIngress"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${data.terraform_remote_state.common.outputs.config_bucket.arn}/${aws_s3_bucket_object.data_ingress_sft_agent_config.key}",
      "${data.terraform_remote_state.common.outputs.config_bucket.arn}/${aws_s3_bucket_object.data_ingress_sft_agent_application_config.key}",
      "${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.arn}/*"
    ]
  }

  statement {
    sid = "ListConfigBucketDI"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      data.terraform_remote_state.common.outputs.config_bucket.arn,
      "${data.terraform_remote_state.common.outputs.config_bucket.arn}/*"
    ]
  }

  statement {
    sid    = "CertificateExportDI"
    effect = "Allow"
    actions = [
      "acm:ExportCertificate",
    ]
    resources = [aws_acm_certificate.data_ingress_server.arn]
  }
}

resource "aws_iam_policy" "sft_agent_task" {
  name        = "SFTAgentTaskDI"
  description = "Custom policy for the sft agent task"
  policy      = data.aws_iam_policy_document.sft_agent_task.json
}
resource "aws_iam_role_policy_attachment" "sft_agent" {
  role       = aws_iam_role.data_ingress_server_task.name
  policy_arn = aws_iam_policy.sft_agent_task.arn
}

resource "aws_iam_role" "data_ingress_server_task" {
  name               = "DataIngressServer"
  assume_role_policy = data.aws_iam_policy_document.data_ingress_server_task_assume_role.json
}

data "aws_iam_policy_document" "data_ingress_server_task_assume_role" {
  statement {
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
    ]
    resources = [aws_acm_certificate.data_ingress_server.arn]
  }

  statement {
    sid = "PublishedBucketKMSDecryptDI"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [data.terraform_remote_state.common.outputs.published_bucket_cmk.arn]
  }

  statement {
    sid = "PublishedBucketReadDIlb"
    actions = [
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = ["arn:aws:s3:::s3fs-test-1234554321", "arn:aws:s3:::s3fs-test-1234554321/*"]
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
