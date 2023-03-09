resource "aws_iam_role" "check_file_landed" {
  name = "check_file_landed_role"
  path = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  inline_policy {
    name   = "lambda_policy"
    policy = data.aws_iam_policy_document.rules_policy_document.json
  }
}

data "aws_iam_policy_document" "rules_policy_document" {

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:AssociateKmsKey"
    ]

    resources = ["*"]

  }
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [var.stage_bucket.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:*Object*",
    ]
    resources = [
      "${var.stage_bucket.arn}/data-ingress/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = [
      var.stage_bucket_kms_key_arn
    ]
  }
    statement {
    actions = [
          "cloudwatch:DescribeAlarms",
    ]
    resources = ["*"]
  }

  statement {
    actions = ["cloudwatch:DisableAlarmActions",
               "cloudwatch:EnableAlarmActions",
               "cloudwatch:SetAlarmState"]
    resources = [var.alarm_arn]
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
