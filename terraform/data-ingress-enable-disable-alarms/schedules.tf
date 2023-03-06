resource "aws_cloudwatch_event_rule" "enable" {
    name = "enable_no_file_landed_alarm"
    description = "enabling alarm"
    schedule_expression = "cron(50 16 6 * *)"
}

resource "aws_cloudwatch_event_target" "schedule_lambda_enable" {
    rule = aws_cloudwatch_event_rule.enable.name
    target_id = "enable_alarm"
    arn = aws_lambda_function.enable_alarms_lambda.arn
}

resource "aws_cloudwatch_event_rule" "disable" {
    name = "disable_no_file_landed_alarm"
    description = "disabling alarm"
    schedule_expression = "cron(05 17 6 * *)"
}

resource "aws_cloudwatch_event_target" "schedule_lambda_disable" {
    rule = aws_cloudwatch_event_rule.disable.name
    target_id = "disable_alarm"
    arn = aws_lambda_function.disable_alarms_lambda.arn
}


