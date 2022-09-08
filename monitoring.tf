resource "aws_cloudwatch_event_rule" "sft_stopped" {
  name          = "sft_stopped_rule_nnNAnb"
  description   = "sft_stopped error"
  event_pattern = <<EOF
{
  "source": ["aws.ecs"],
  "detail-type": ["ECS Task State Change","ECS Container Instance State Change"],
  "detail": {
    "clusterArn": ["${aws_ecs_cluster.data_ingress_cluster.arn}"],
    "lastStatus": ["STOPPED"]}
}
EOF
}

resource "aws_cloudwatch_metric_alarm" "sft_stopped" {
  alarm_name                = "sft_stopped_nn"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "30"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "This metric monitors cluster termination with errors"
  insufficient_data_actions = []
  alarm_actions             = [""]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.sft_stopped.name
  }
  tags = merge(
    local.common_repo_tags,
    {
      Name              = "sft_stopped",
      notification_type = "Error"
      severity          = "Critical"
    },
  )
}


//
//resource "aws_ssm_document" "enable_rule" {
//  name            = "enable_rule"
//  document_type   = "Command"
//  document_format = "JSON"
//  tags = merge(
//    local.common_repo_tags,
//    {
//      Name = "data_ingress_EnableRule_ssm"
//    }
//  )
//  content = <<DOC
//  {
//     "schemaVersion": "2.2",
//     "description": "State Manager Bootstrap ddd",
//     "parameters": {},
//     "mainSteps": [
//        {
//           "action": "aws:runShellScript",
//           "name": "configureServer",
//           "inputs": {
//              "runCommand": [
//                 "aws ec2 create-tags --resources  "
//              ]
//           }
//        }
//     ]
//  }
//DOC
//}
//
//resource "aws_cloudwatch_event_rule" "enable_rule" {
//  name                = "EnableRuleTwo"
//  description         = "Stop instances nightly"
//  schedule_expression = "cron(16 14 * * ? *)"
//
//  tags = merge(
//    local.common_repo_tags,
//    {
//      Name = "data_ingress_EnableRule"
//    }
//  )
//}
//
//
//resource "aws_cloudwatch_event_target" "enable_rule" {
//  target_id = "EnableRule"
//  arn       = aws_ssm_document.enable_rule.arn
//  rule      = aws_cloudwatch_event_rule.enable_rule.name
//  role_arn  = aws_iam_role.data_ingress_server.arn
//  run_command_targets {
//    key    = "InstanceIds"
//    values = [""]
//  }
//
//}


//resource "aws_cloudwatch_event_target" "stop_instances" {
//  target_id = "StopInstance"
//  arn       = "arn:aws:ssm:${var.region}::document/AWS-RunShellScript"
//  input     = "{\"commands\":[\"halt\"]}"
//  rule      = aws_cloudwatch_event_rule.enable_rule.name
//  role_arn  = aws_iam_role.data_ingress_server.arn
//  run_command_targets {
//    key    = "tag:Terminate"
//    values = ["midnight"]
//  }
//}
