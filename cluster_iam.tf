resource "aws_iam_role" "data_ingress_server" {
  name               = "DataingressCluster"
  assume_role_policy = data.aws_iam_policy_document.data_ingress_server_assume_role.json
  tags = merge(
    local.common_repo_tags,
    {
      Name = "data_ingress_server_role"
    }
  )
}

resource "aws_iam_instance_profile" "data_ingress_server" {
  name = "DataingressCluster"
  role = aws_iam_role.data_ingress_server.name
}

resource "aws_iam_role_policy_attachment" "ec2_for_ssm_attachment" {
  role       = aws_iam_role.data_ingress_server.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "data_ingress_cluster_ecs" {
  role       = aws_iam_role.data_ingress_server.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "data_ingress_server_ecs_cwasp" {
  role       = aws_iam_role.data_ingress_server.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "data_ingress_tagging_attachment" {
  role       = aws_iam_role.data_ingress_server.name
  policy_arn = aws_iam_policy.data_ingress_server_tagging.arn
}

resource "aws_iam_policy" "data_ingress_server_tagging" {
  name        = "DataIngressEC2TaggingItself"
  description = "Allow Data Ingress EC2s modify their tags"
  policy      = data.aws_iam_policy_document.data_ingress_server_tagging_policy.json
}

data "aws_iam_policy_document" "data_ingress_server_tagging_policy" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:*Tags",
    ]

    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "data_ingress_server_assume_role" {
  statement {
    sid = "ECSAssumeRole"
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "data_ingress_cluster_monitoring_logging" {
  statement {
    sid    = "AllowAccessLogGroups"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]

    resources = [aws_cloudwatch_log_group.data_ingress_cluster.arn]
  }
}

data "aws_iam_policy_document" "kms_key_use" {
  statement {
    sid    = "AllowKMSPB"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]
    resources = [data.terraform_remote_state.common.outputs.config_bucket_cmk.arn,
                 data.terraform_remote_state.common.outputs.published_bucket_cmk.arn,
                 data.terraform_remote_state.common.outputs.stage_data_ingress_bucket_cmk.arn]
  }
}

resource "aws_iam_role_policy_attachment" "kms_key_use" {
  role       = aws_iam_role.data_ingress_server.name
  policy_arn = aws_iam_policy.kms_key_use.arn
}

resource "aws_iam_policy" "kms_key_use" {
  name        = "DataIngressKMSPB"
  description = "Allow data ingress cluster to log"
  policy      = data.aws_iam_policy_document.kms_key_use.json
}

resource "aws_iam_role_policy_attachment" "data_ingress_cluster_monitoring_logging" {
  role       = aws_iam_role.data_ingress_server.name
  policy_arn = aws_iam_policy.data_ingress_cluster_monitoring_logging.arn
}

data "aws_iam_policy_document" "data_ingress_server_ni" {
  statement {
    effect = "Allow"

    actions = [
      "ecs:DescribeContainerInstances"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "CertificateExportDI"
    effect = "Allow"
    actions = [
      "acm:ExportCertificate",
      "acm:GetCertificate",
    ]
    resources = [aws_acm_certificate.data_ingress_server.arn]
  }

  statement {

    effect = "Allow"

    actions = [
      "ec2:AttachNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:TerminateInstances"
    ]
    condition {
      test = "StringEquals"
      variable = "ec2:ResourceTag/Owner"
      values = [local.name]
    }
    resources = [
      "*"
    ]
  }

}

data "aws_iam_role" "AWSServiceRoleForAutoScaling" {
  name = "AWSServiceRoleForAutoScaling"
}

resource "aws_iam_role_policy_attachment" "data_ingress_ni" {
  role       = aws_iam_role.data_ingress_server.name
  policy_arn = aws_iam_policy.data_ingress_ni.arn
}

resource "aws_iam_policy" "data_ingress_ni" {
  name        = "DataIngressClusterni"
  description = "Allow data ingress cluster to log"
  policy      = data.aws_iam_policy_document.data_ingress_server_ni.json
}

resource "aws_iam_policy" "data_ingress_cluster_monitoring_logging" {
  name        = "DataIngressClusterLoggingPolicy"
  description = "Allow data ingress cluster to log"
  policy      = data.aws_iam_policy_document.data_ingress_cluster_monitoring_logging.json
}

data "aws_iam_policy_document" "data_ingress_get_secret" {
  statement {
    sid    = "GetDataIngressSecret"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [data.aws_secretsmanager_secret.trendmicro.arn]
  }
  statement {
    sid       = "DataIngressGetCAMgmtCertS3"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.arn}/*"]
  }
}

resource "aws_iam_policy" "data_ingress_get_secret" {
  name        = "DataIngressGetSecret"
  description = "Allow data ingress instances to get secret"
  policy      = data.aws_iam_policy_document.data_ingress_get_secret.json
}

resource "aws_iam_role_policy_attachment" "data_ingress_get_secret" {
  role       = aws_iam_role.data_ingress_server.name
  policy_arn = aws_iam_policy.data_ingress_get_secret.arn
}

data "aws_iam_policy_document" "stage_bucket_all" {

  statement {
    sid = "StageBucketS3All"
    actions = [
      "s3:*"
    ]
    resources = [data.terraform_remote_state.common.outputs.data_ingress_stage_bucket.arn, "${data.terraform_remote_state.common.outputs.data_ingress_stage_bucket.arn}/*"]
  }
}

resource "aws_iam_policy" "stage_bucket_all" {
  name        = "stageBucketAll"
  description = "Allow data ingress instances to read and write to test bucket"
  policy      = data.aws_iam_policy_document.stage_bucket_all.json
}

resource "aws_iam_role_policy_attachment" "stage_bucket_all" {
  role       = aws_iam_role.data_ingress_server.name
  policy_arn = aws_iam_policy.stage_bucket_all.arn
}
