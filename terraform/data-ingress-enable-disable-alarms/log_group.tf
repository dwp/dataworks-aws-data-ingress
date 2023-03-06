resource "aws_cloudwatch_log_group" "data_ingress_enable_disable_alarms_lambda" {
  name              = "/app/data_ingress/enable_disable_alarms_lambda"
  retention_in_days = 180
  tags = merge(
    var.common_repo_tags,
    {
      Name = "data_ingress_enable_disable_alarms_lambda"
    }
  )
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
