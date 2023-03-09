data "archive_file" "check_file_landed" {
  type             = "zip"
  source_file      = "${path.module}/check_file_landed.py"
  output_file_mode = "0666"
  output_path      = "${path.module}/bin/check_file_landed.zip"
}

resource "aws_lambda_function" "check_file_landed" {
  filename         = data.archive_file.check_file_landed.output_path
  function_name    = "check_file_landed"
  handler          = "check_file_landed.lambda_handler"
  source_code_hash = data.archive_file.check_file_landed.output_base64sha256
  role             = aws_iam_role.check_file_landed.arn

  runtime = "python3.9"

  environment {
    variables = {
      bucket = var.stage_bucket.id
      filename_prefix = var.filename_prefix
      prefix = var.prefix
      alarm_name = var.alarm_name
    }
  }
}

resource "aws_lambda_permission" "check_file_landed" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.check_file_landed.function_name
    principal = "events.amazonaws.com"
}
