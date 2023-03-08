resource "aws_cloudwatch_event_rule" "trigger" {
    name = "trigger_lambda_check_file_landed"
    description = "execute lambda"
    schedule_expression = replace("cron(${var.shut_down_time})", "* *", "* ? *")
}

resource "aws_cloudwatch_event_target" "schedule_lambda_check_file_landed" {
    rule = aws_cloudwatch_event_rule.trigger.name
    target_id = "lambda_check_file_landed"
    arn = aws_lambda_function.check_file_landed.arn
}
