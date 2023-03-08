data "archive_file" "enable_disable_rules_lambda_zip" {
  type             = "zip"
  source_file      = "${path.module}/enable_disable_rules_lambda.py"
  output_file_mode = "0666"
  output_path      = "${path.module}/bin/enable_disable_rules_lambda.zip"
}

resource "aws_lambda_function" "enable_rules_lambda" {
  filename         = data.archive_file.enable_disable_rules_lambda_zip.output_path
  function_name    = "enable_disable_rules_lambda_enable"
  handler          = "enable_disable_rules_lambda.lambda_handler"
  source_code_hash = data.archive_file.enable_disable_rules_lambda_zip.output_base64sha256
  role             = aws_iam_role.enable_disable_rules_lambda.arn

  runtime = "python3.9"

  environment {
    variables = {
      action = "enable"
      rule_name = var.rule_name
      alarm_name = var.alarm_name
    }
  }
}

resource "aws_lambda_function" "disable_rules_lambda" {
  filename         = data.archive_file.enable_disable_rules_lambda_zip.output_path
  function_name    = "enable_disable_rules_lambda_disable"
  handler          = "enable_disable_rules_lambda.lambda_handler"
  source_code_hash = data.archive_file.enable_disable_rules_lambda_zip.output_base64sha256
  role             = aws_iam_role.enable_disable_rules_lambda.arn
  runtime = "python3.9"

  environment {
    variables = {
      action = "disable"
      rule_name = var.rule_name
      alarm_name = var.alarm_name
    }
  }
}

resource "aws_lambda_permission" "permission_to_run_lambda_disable" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.disable_rules_lambda.function_name
    principal = "events.amazonaws.com"
}

resource "aws_lambda_permission" "permission_to_run_lambda_enable" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.enable_rules_lambda.function_name
    principal = "events.amazonaws.com"
}
