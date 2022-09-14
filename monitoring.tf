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
  alarm_actions             = [local.monitoring_topic_arn]
  lifecycle {ignore_changes = [tags]}
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.sft_stopped.name
  }
  tags = merge(
    local.common_repo_tags,
    {
      Name              = "ch_sft_receiver_container_stopped",
      notification_type = "Information"
      severity          = "Critical"
    },
  )
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
  alarm_actions             = [local.monitoring_topic_arn]
  lifecycle {ignore_changes = [tags]}
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.sft_running.name
  }
  tags = merge(
    local.common_repo_tags,
    {
      Name              = "ch_sft_receiver_container_running",
      notification_type = "Information"
      severity          = "Critical"
    },
  )
}

resource "aws_cloudwatch_event_rule" "file_landed" {
  name          = "file_landed_on_staging_rule"
  description   = "checks that file landed on staging bucket"
  event_pattern = <<EOF
{
  "source": ["aws.s3"],
  "detail-type": ["Object Created"],
  "detail": {
    "bucket": {
      "name":["${local.stage_bucket.id}"]},
    "object": {
       "key": [{"prefix":"${local.companies_s3_prefix}/${local.filename_prefix}-"}]}
  }
}
EOF
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket      = local.stage_bucket.id
  eventbridge = true
}

resource "aws_cloudwatch_metric_alarm" "file_landed" {
  alarm_name                = "file_landed_on_staging"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring stage bucket"
  insufficient_data_actions = []
  alarm_actions             = [local.monitoring_topic_arn]
  lifecycle {ignore_changes = [tags]}
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.file_landed.name
  }
  tags = merge(
    local.common_repo_tags,
    {
      Name              = "ch_completed_all_steps",
      notification_type = "Information",
      severity          = "Critical"
    },
  )
}
