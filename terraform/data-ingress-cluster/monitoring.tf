resource "aws_cloudwatch_event_rule" "sft_stopped" {
  name          = "ch_sft_receiver_container_stopped_rule"
  description   = "ch sft receiver container stopped"
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
  alarm_name                = "ch_sft_receiver_container_stopped"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "This metric monitors container termination"
  insufficient_data_actions = []
  alarm_actions             = [var.monitoring_topic_arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.sft_stopped.name
  }
  tags = merge(
    var.common_repo_tags,
    {
      Name              = "ch_sft_receiver_container_stopped",
      notification_type = "Information"
      severity          = "Critical"
    },
  )
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_cloudwatch_event_rule" "sft_running" {
  name          = "ch_sft_receiver_container_running_rule"
  description   = "ch sft receiver container running"
  event_pattern = <<EOF
{
  "source": ["aws.ecs"],
  "detail-type": ["ECS Task State Change"],
  "detail": {
    "clusterArn": ["${aws_ecs_cluster.data_ingress_cluster.arn}"],
    "lastStatus": ["RUNNING"]}
}
EOF
}

resource "aws_cloudwatch_metric_alarm" "sft_running" {
  alarm_name                = "ch_sft_receiver_container_running"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "This metric monitors when the container starts"
  insufficient_data_actions = []
  alarm_actions             = [var.monitoring_topic_arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.sft_running.name
  }
  tags = merge(
    var.common_repo_tags,
    {
      Name              = "ch_sft_receiver_container_running",
      notification_type = "Information"
      severity          = "Critical"
    },
  )
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_cloudwatch_event_rule" "file_landed" {
  name          = "CH_file_landed_on_staging_rule"
  description   = "checks that file landed on staging bucket"
  event_pattern = <<EOF
{
  "source": ["aws.s3"],
  "detail-type": ["Object Created"],
  "detail": {
    "bucket": {
      "name":["${var.stage_bucket.id}"]},
    "object": {
       "key": [{"prefix":"${var.companies_s3_prefix}/${var.filename_prefix}-"}]}
  }
}
EOF
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket      = var.stage_bucket.id
  eventbridge = true
}

resource "aws_cloudwatch_metric_alarm" "file_landed" {
  alarm_name                = "CH_file_landed_on_staging"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring stage bucket"
  insufficient_data_actions = []
  alarm_actions             = [var.monitoring_topic_arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.file_landed.name
  }
  tags = merge(
    var.common_repo_tags,
    {
      Name              = "ch_completed_all_steps",
      notification_type = "Information",
      severity          = "Critical"
    },
  )
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_cloudwatch_metric_alarm" "no_file_landed" {
  alarm_name                = "no_CH_file_landed_on_staging"
  actions_enabled           = false
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "300" #259200three days
  statistic                 = "SampleCount"
  threshold                 = "1"
  alarm_description         = "Monitoring stage bucket"
  insufficient_data_actions = [var.monitoring_topic_arn]
  alarm_actions             = [var.monitoring_topic_arn]
//  treat_missing_data        = "breaching"
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.file_landed.name
  }
  tags = merge(
    var.common_repo_tags,
    {
      Name              = "no_CH_file_landed_on_staging",
      notification_type = "Error",
      severity          = "Critical"
    },
  )
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
