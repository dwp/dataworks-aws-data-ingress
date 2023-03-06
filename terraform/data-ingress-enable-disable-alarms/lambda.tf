data "archive_file" "enable_disable_alarms_lambda_zip" {
  type             = "zip"
  source_file      = "${path.module}/enable_disable_alarms_lambda.py"
  output_file_mode = "0666"
  output_path      = "${path.module}/bin/enable_disable_alarms_lambda.zip"
}

resource "aws_lambda_function" "enable_alarms_lambda" {
  filename         = data.archive_file.enable_disable_alarms_lambda_zip.output_path
  function_name    = "enable_disable_alarms_lambda_enable"
  handler          = "enable_disable_alarms_lambda.lambda_handler"
  source_code_hash = data.archive_file.enable_disable_alarms_lambda_zip.output_base64sha256
  role             = aws_iam_role.enable_disable_alarms_lambda.arn

  runtime = "python3.9"

  environment {
    variables = {
      log_path = aws_cloudwatch_log_group.data_ingress_enable_disable_alarms_lambda.name
      action = "enable"
      alarm_name = var.alarm_name
    }
  }
}

resource "aws_lambda_function" "disable_alarms_lambda" {
  filename         = data.archive_file.enable_disable_alarms_lambda_zip.output_path
  function_name    = "enable_disable_alarms_lambda_disable"
  handler          = "enable_disable_alarms_lambda.lambda_handler"
  source_code_hash = data.archive_file.enable_disable_alarms_lambda_zip.output_base64sha256
  role             = aws_iam_role.enable_disable_alarms_lambda.arn
  runtime = "python3.9"

  environment {
    variables = {
      log_path = aws_cloudwatch_log_group.data_ingress_enable_disable_alarms_lambda.name
      action = "disable"
      alarm_name = var.alarm_name
    }
  }
}

resource "aws_lambda_permission" "permission_to_run_lambda" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.disable_alarms_lambda.function_name
    principal = "events.amazonaws.com"
}

resource "aws_lambda_permission" "permission_to_run_lambda" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.enable_alarms_lambda.function_name
    principal = "events.amazonaws.com"
}
