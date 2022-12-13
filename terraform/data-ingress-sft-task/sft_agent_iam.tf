data "aws_iam_policy_document" "sft_agent_task" {

  statement {
    sid = "PullIngressSFTAgentImageECRrepository"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = ["arn:aws:ecr:${var.region}:${var.account[var.management_account[var.environment]]}:repository/${var.ecr_repository_name}"]
  }

  statement {
    sid       = "AllowKMSDecryptdataIngress"
    actions   = ["kms:Decrypt"]
    resources = [var.config_bucket_kms_key_arn]
  }

  statement {
    sid     = "PullSFTAgentConfigS3dataIngress"
    actions = ["s3:GetObject"]
    resources = [
      "${var.config_bucket.arn}/${aws_s3_bucket_object.data_ingress_sft_agent_config_receiver.key}",
      "${var.config_bucket.arn}/${aws_s3_bucket_object.data_ingress_sft_agent_config_sender.key}",
      "${var.config_bucket.arn}/${aws_s3_bucket_object.data_ingress_sft_agent_application_config_receiver.key}",
      "${var.config_bucket.arn}/${aws_s3_bucket_object.data_ingress_sft_agent_application_config_sender.key}",
      "${var.config_bucket.arn}/*"
    ]
  }
  statement {
    sid     = "ListConfigBucketDI"
    actions = ["s3:ListBucket"]
    resources = [
      var.config_bucket.arn,
      "${var.config_bucket.arn}/*"
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
}

resource "aws_iam_policy" "sft_agent_task" {
  name        = "IngressSFTAgentTask"
  description = "Custom policy for the ingress sft agent task"
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

data "aws_iam_policy_document" "data_ingress_server_task_certs" {

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
    sid       = "DataIngressGetCAMgmtCertS3"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${var.cert_bucket.arn}/*"]
  }
}

resource "aws_iam_policy" "data_ingress_server_task_certs" {
  name        = "DataIngressServerCerts"
  description = "Custom policy for data ingress server"
  policy      = data.aws_iam_policy_document.data_ingress_server_task_certs.json
}

resource "aws_iam_role_policy_attachment" "data_ingress_server_task_certs" {
  role       = aws_iam_role.data_ingress_server_task.name
  policy_arn = aws_iam_policy.data_ingress_server_task_certs.arn
}

resource "aws_iam_role_policy_attachment" "data_ingress_server_export_certificate_bucket_read" {
  role       = aws_iam_role.data_ingress_server_task.name
  policy_arn = "arn:aws:iam::${var.account[var.environment]}:policy/CertificatesBucketRead"
}

resource "aws_iam_role_policy_attachment" "data_ingress_server_ebs_cmk_instance_encrypt_decrypt" {
  role       = aws_iam_role.data_ingress_server_task.name
  policy_arn = "arn:aws:iam::${var.account[var.environment]}:policy/EBSCMKInstanceEncryptDecrypt"
}

data "aws_iam_policy_document" "stage_bucket_all" {
  statement {
  sid       = "BucketsKMSDecryptDI"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [var.stage_bucket_kms_key_arn]
  }
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [
      var.stage_bucket.arn
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:*Object*",
    ]
    resources = [
      "${var.stage_bucket.arn}/e2e/*",
      "${var.stage_bucket.arn}/data-ingress/*"
    ]
  }
}

resource "aws_iam_policy" "stage_bucket_all" {
  name        = "stageBucketAlltask"
  description = "Allow task to read and write to data ingress bucket and use kms key"
  policy      = data.aws_iam_policy_document.stage_bucket_all.json
}

resource "aws_iam_role_policy_attachment" "stage_bucket_all" {
  role       = aws_iam_role.data_ingress_server_task.name
  policy_arn = aws_iam_policy.stage_bucket_all.arn
}

data "aws_iam_policy_document" "sft_get_secret" {
  statement {
    sid    = "GetTrendMicroSecret"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [var.trendmicro_secret_arn]

  }
}

resource "aws_iam_policy" "sft_get_secret" {
  name        = "GetTrendMicroSecretSFT"
  description = "Allow data ingress instances to get secret"
  policy      = data.aws_iam_policy_document.sft_get_secret.json
}

resource "aws_iam_role_policy_attachment" "sft_get_secret" {
  role       = aws_iam_role.data_ingress_server_task.name
  policy_arn = aws_iam_policy.sft_get_secret.arn
}
