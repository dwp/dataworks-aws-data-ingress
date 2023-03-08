resource "aws_cloudwatch_event_rule" "enable" {
    name = "enable_no_file_landed_rule"
    description = "enabling rule"
    schedule_expression = "cron(58 10 8 * ? *)"
}

resource "aws_cloudwatch_event_target" "schedule_lambda_enable" {
    rule = aws_cloudwatch_event_rule.enable.name
    target_id = "enable_rule"
    arn = aws_lambda_function.enable_rules_lambda.arn
}

resource "aws_cloudwatch_event_rule" "disable" {
    name = "disable_no_file_landed_rule"
    description = "disabling rule"
    schedule_expression = "cron(8 11 8 * ? *)"
}

resource "aws_cloudwatch_event_target" "schedule_lambda_disable" {
    rule = aws_cloudwatch_event_rule.disable.name
    target_id = "disable_rule"
    arn = aws_lambda_function.disable_rules_lambda.arn
}
