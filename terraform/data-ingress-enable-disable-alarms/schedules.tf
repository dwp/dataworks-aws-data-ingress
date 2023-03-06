resource "aws_cloudwatch_event_rule" "enable" {
    name = "enable no file landed alarm"
    description = "enabling alarm"
    schedule_expression = "cron(10 16 6 * *)"
}

resource "aws_cloudwatch_event_target" "schedule_lambda" {
    rule = aws_cloudwatch_event_rule.enable.name
    target_id = "enable_alarm"
    arn = aws_lambda_function.enable_alarms_lambda.arn
}

resource "aws_cloudwatch_event_rule" "disable" {
    name = "disable no file landed alarm"
    description = "disabling alarm"
    schedule_expression = "cron(25 16 6 * *)"
}

resource "aws_cloudwatch_event_target" "schedule_lambda" {
    rule = aws_cloudwatch_event_rule.disable.name
    target_id = "disable_alarm"
    arn = aws_lambda_function.disable_alarms_lambda.arn
}


