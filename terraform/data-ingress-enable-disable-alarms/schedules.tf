resource "aws_cloudwatch_event_rule" "enable" {
    name = "enable_no_file_landed_alarm"
    description = "enabling alarm"
    schedule_expression = "cron(0 10 7 * ? *)"
}

resource "aws_cloudwatch_event_target" "schedule_lambda_enable" {
    rule = aws_cloudwatch_event_rule.enable.name
    target_id = "enable_alarm"
    arn = aws_lambda_function.enable_alarms_lambda.arn
}

resource "aws_cloudwatch_event_rule" "disable" {
    name = "disable_no_file_landed_alarm"
    description = "disabling alarm"
    schedule_expression = "cron(12 10 7 * ? *)"
}

resource "aws_cloudwatch_event_target" "schedule_lambda_disable" {
    rule = aws_cloudwatch_event_rule.disable.name
    target_id = "disable_alarm"
    arn = aws_lambda_function.disable_alarms_lambda.arn
}


