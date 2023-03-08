resource "aws_iam_role" "enable_disable_rules_lambda" {
  name = "enable_disable_rules_lambda_role"
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
      "events:Describe*",
      "events:List*"
    ]
    resources = [
      "*"]
  }

    statement {
    actions = [
      "events:DisableRule",
      "events:EnableRule",
    ]
    resources = [var.rule_arn]
  }

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
          "cloudwatch:DescribeAlarms",
    ]
    resources = ["*"]
  }

  statement {
    actions = ["cloudwatch:DisableAlarmActions",
               "cloudwatch:EnableAlarmActions"]
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
