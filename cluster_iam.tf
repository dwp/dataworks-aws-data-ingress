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
      "kms:*"
    ]

    resources = ["arn:aws:kms:*:${local.account[local.environment]}:key/*"]
  }
}
resource "aws_iam_role_policy_attachment" "kms_key_use" {
  role       = aws_iam_role.data_ingress_server.name
  policy_arn = aws_iam_policy.kms_key_use.arn
}

resource "aws_iam_policy" "kms_key_use" {
  name        = "DataIngressKMSPB"
  description = "Allow data egress cluster to log"
  policy      = data.aws_iam_policy_document.kms_key_use.json
}

resource "aws_iam_role_policy_attachment" "data_ingress_cluster_monitoring_logging" {
  role       = aws_iam_role.data_ingress_server.name
  policy_arn = aws_iam_policy.data_ingress_cluster_monitoring_logging.arn
}

resource "aws_iam_policy" "data_ingress_cluster_monitoring_logging" {
  name        = "DataIngressClusterLoggingPolicyNew"
  description = "Allow data egress cluster to log"
  policy      = data.aws_iam_policy_document.data_ingress_cluster_monitoring_logging.json
}